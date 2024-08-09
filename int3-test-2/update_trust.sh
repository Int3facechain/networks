#!/bin/bash

# Parameters
RPC_SERVER="5.78.111.245:26657"
CHAIN_CONFIG_PATH="$HOME/.int3faced/config/config.toml"
TRUST_HEIGHT_OFFSET=1000

# Function to exit on error with a message
exit_on_error() {
    echo "$1"
    exit 1
}

# Retrieve the current block height
CURRENT_HEIGHT=$(curl -s http://$RPC_SERVER/block | jq -r '.result.block.header.height')

# Check if we retrieved a valid block height
if [[ -z "$CURRENT_HEIGHT" || "$CURRENT_HEIGHT" -le "$TRUST_HEIGHT_OFFSET" ]]; then
    exit_on_error "Failed to retrieve a valid block height or the block height is too low."
fi

# Calculate the trust height
TRUST_HEIGHT=$((CURRENT_HEIGHT - TRUST_HEIGHT_OFFSET))

# Retrieve the block hash at the trust height
TRUST_HASH=$(curl -s "http://$RPC_SERVER/block?height=$TRUST_HEIGHT" | jq -r '.result.block_id.hash')

# Check if we retrieved a valid block hash
if [[ -z "$TRUST_HASH" ]]; then
    exit_on_error "Failed to retrieve a valid block hash for height $TRUST_HEIGHT."
fi

# Update the trust_height and trust_hash in the config file
sed -i.bak -E "s/^trust_height = .*/trust_height = $TRUST_HEIGHT/" "$CHAIN_CONFIG_PATH"
sed -i.bak -E "s/^trust_hash = .*/trust_hash = \"$TRUST_HASH\"/" "$CHAIN_CONFIG_PATH"

# Confirm the updates
echo "Updated config.toml with trust_height = $TRUST_HEIGHT and trust_hash = $TRUST_HASH"
echo "Trust Height: $TRUST_HEIGHT"
echo "Trust Hash: $TRUST_HASH"