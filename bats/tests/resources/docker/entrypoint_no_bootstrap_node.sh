#!/bin/bash
# wait until the node service is ready (the node service is defined in pyrsia-integration-tests/bats/tests/resources/docker/docker-compose_auth_nodes.yml)
# shellcheck disable=SC2034
for i in {0..20}
do
  # obtain the boot address from the auth node service (defined in pyrsia-integration-tests/bats/tests/resources/docker/docker-compose_auth_nodes.yml)
  NODE_STATUS=$(curl -s http://auth_node_with_build_service:7889/status)
  BOOTADDR=$(jq -r ".peer_addrs[0]"  <<< "$NODE_STATUS")

  # debug
  echo "NODE STATUS [curl -s http://auth_node_with_build_service:7889/status] = $(curl -s http://auth_node_with_build_service:7889/status)"

  if [[ "$BOOTADDR" == *"ip4/127"* ]]; then
     BOOTADDR=$(jq -r ".peer_addrs[1]"  <<< "$NODE_STATUS")
  fi
  if [ -n "$BOOTADDR" ] && [ "$BOOTADDR" != "null" ]; then
    # the boot address obtained, break
    break
  fi
  # wait another 5 sec for the  auth node service
  sleep 5
done

# debug
echo "BOOTADDR: $BOOTADDR"

# terminate if the boot address peer not found
if [ -z "$BOOTADDR" ] || [ "$BOOTADDR" == "null" ]; then
  exit 1
fi

# debug
echo "NODE START COMMAND: /src/pyrsia/target/debug/pyrsia_node -P $BOOTADDR --host 0.0.0.0 --listen /ip4/0.0.0.0/tcp/44000"

# start the pyrsia node (no bootstrap, peer it to   auth_node_with_build_service node)
chmod +x /src/pyrsia/target/debug/pyrsia_node
RUST_LOG=pyrsia=debug /src/pyrsia/target/debug/pyrsia_node "$@" -P "$BOOTADDR" --host 0.0.0.0 --listen /ip4/0.0.0.0/tcp/44000
