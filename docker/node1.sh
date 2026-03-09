#!/bin/sh
# Node 1: Whitelisted
set -e

# Initialize with genesis
geth --datadir /app/node1 init /app/docker/genesis.json

# Import the signer account private key into keystore
echo "whitelistnodepassword" | geth --datadir /app/node1 account import /app/docker/node1_keys.prv 2>/dev/null || echo "Account may already exist"

# Import the admin account (for whitelisting transactions)
echo "whitelistnodepassword" | geth --datadir /app/node1 account import /app/docker/admin_key.prv 2>/dev/null || echo "Admin account may already exist"

# Start node with whitelisted address (Clique signer)
# Note: For Clique, accounts are imported into keystore above
# The --unlock flag is deprecated, Clique will use accounts from keystore automatically
# Note: Clique sealing is deprecated in newer Geth versions, blocks may not be produced automatically
geth --datadir /app/node1 \
  --networkid 1234 --nodiscover \
  --http --http.addr 0.0.0.0 --http.port 8545 \
  --port 30303 \
  --http.api eth,net,web3,admin,miner \
  --mine --miner.etherbase 0xca6b49ee60cdd276ab503fbd6fb80a3cfbc06ffc \
  --allow-insecure-unlock