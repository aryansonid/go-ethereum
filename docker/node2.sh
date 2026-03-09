#!/bin/sh
# Node 2: Not whitelisted
set -e

# Initialize with genesis
geth --datadir /app/node2 init /app/docker/genesis.json

# Import the signer account private key into keystore
echo "whitelistnodepassword" | geth --datadir /app/node2 account import /app/docker/node2_keys.prv 2>/dev/null || echo "Account may already exist"

# Import the admin account (for whitelisting transactions)
echo "whitelistnodepassword" | geth --datadir /app/node2 account import /app/docker/admin_key.prv 2>/dev/null || echo "Admin account may already exist"

# Start node with non-whitelisted address (Clique signer)
# Note: For Clique, accounts are imported into keystore above
# The --unlock flag is deprecated, Clique will use accounts from keystore automatically
# Note: Clique sealing is deprecated in newer Geth versions, blocks may not be produced automatically
geth --datadir /app/node2 \
  --networkid 1234 --nodiscover \
  --http --http.addr 0.0.0.0 --http.port 8546 \
  --port 30304 \
  --http.api eth,net,web3,admin,miner \
  --mine --miner.etherbase 0xab52b2c71f61cd9447a932c0cb55d1752571dab8 \
  --allow-insecure-unlock