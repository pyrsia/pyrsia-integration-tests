#!/bin/bash

# start pyrsia node (bootstrap no build service)
chmod +x /src/pyrsia/target/debug/pyrsia_node
BOOTADDR=$(curl -s http://boot.pyrsia.link/status | jq -r ".peer_addrs[0]")
/src/pyrsia/target/debug/pyrsia_node "$@" -P "$BOOTADDR" --host 0.0.0.0 --listen /ip4/0.0.0.0/tcp/44000
