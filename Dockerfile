# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.26-alpine AS builder

RUN apk add --no-cache gcc musl-dev linux-headers git

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum
WORKDIR /go-ethereum
RUN mkdir -p build/bin && \
    CGO_ENABLED=0 go build -ldflags="-extldflags=-static" -o build/bin/geth ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programmatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"

# Copy scripts for node setup
COPY docker/node1.sh /app/docker/node1.sh
COPY docker/node2.sh /app/docker/node2.sh
COPY docker/password.txt /app/docker/password.txt
COPY docker/genesis.json /app/docker/genesis.json
COPY docker/node1_keys.prv /app/docker/node1_keys.prv
COPY docker/node2_keys.prv /app/docker/node2_keys.prv
COPY docker/admin_key.prv /app/docker/admin_key.prv
RUN chmod +x /app/docker/node1.sh /app/docker/node2.sh
