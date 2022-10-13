#!/usr/bin/env bash

# the tests temp dir
PYRSIA_TEMP_DIR=/tmp/pyrsia_tests/pyrsia
# the pyrsia binaries
PYRSIA_TARGET_DIR=$PYRSIA_TEMP_DIR/target/release

_common_setup() {
  # load the bats "extensions"
  load '../lib/test_helper/bats-support/load'
  load '../lib/test_helper/bats-assert/load'
}

_common_setup_file() {
  echo "Setting up the test environment..." >&3
  if [ -z "$GIT_REPO" ]; then
    GIT_REPO="https://github.com/pyrsia/pyrsia.git"
  fi
  if [ -z "$GIT_BRANCH" ]; then
    GIT_BRANCH="main"
  fi
  # clone or update the sources
  if [ -d $PYRSIA_TEMP_DIR/.git ]; then
    git --git-dir=$PYRSIA_TEMP_DIR/.git fetch
    git --git-dir=$PYRSIA_TEMP_DIR/.git --work-tree=$PYRSIA_TEMP_DIR merge origin/$GIT_BRANCH
  else
    mkdir -p $PYRSIA_TEMP_DIR
    git clone --branch $GIT_BRANCH $GIT_REPO $PYRSIA_TEMP_DIR
  fi

  echo "Building the Pyrsia CLI sources (Pyrsia CLI source dir: $PYRSIA_TEMP_DIR), it might take a while..." >&3
  cargo build -q --profile=release --package=pyrsia_cli --manifest-path=$PYRSIA_TEMP_DIR/Cargo.toml
  echo "Building Pyrsia CLI completed!" >&3
  echo "Building the Pyrsia node docker image and starting the container, it might take a while..." >&3
  DOCKER_COMPOSE_PATH=$1;
  docker-compose -f "$DOCKER_COMPOSE_PATH" up -d
  sleep 10
  # check periodically if the node is up (using pyrsia ping)
  # shellcheck disable=SC2034
  for i in {0..20..1}
    do
      ping_output=$("$PYRSIA_TARGET_DIR"/pyrsia ping)
      if [[  "$ping_output" == *"Successful"* ]]; then
        break
      fi
      sleep 10
    done
  echo "The Docker Pyrsia node container is up!" >&3
  echo "Docker compose tests services: $(docker-compose -f "$DOCKER_COMPOSE_PATH" ps --services)"
  echo "The tests environment is ready!" >&3
  echo "Running tests..." >&3
}

_common_teardown_file() {
  unset BATS_TEST_TIMEOUT
  echo " " >&3
  CLEAN_UP_TEST_ENVIRONMENT=true
  # print docker logs
  #docker-compose -f "$DOCKER_COMPOSE_PATH" logs >&3
  if [ "$CLEAN_UP_TEST_ENVIRONMENT" = true ]; then
    echo "Tearing down the tests environment..." >&3
    echo "Cleaning up the docker images and containers..."  >&3
    docker-compose -f "$DOCKER_COMPOSE_PATH" down --rmi all
  else
    echo "Stopping the docker containers..." >&3
    docker-compose -f "$DOCKER_COMPOSE_PATH" stop
    echo "WARNING: The docker images/container was not removed because 'CLEAN_UP_TEST_ENVIRONMENT'=FALSE'"  >&3
  fi
  echo "Done tearing the tests environment!" >&3
}

# add authorized node
_set_node_as_authorized() {
  PEER_ID=""
  local node_hostname=$1;
  # wait until the node is ready (the node services are defined in pyrsia-integration-tests/bats/tests/resources/docker/docker-compose_auth_nodes.yml)
  # shellcheck disable=SC2034
  for i in {0..20}
  do
    # obtain the peer id form the node
    PEER_ID=$(curl -s http://"$node_hostname"/status | jq -r ".peer_id")
    if [ -n "$PEER_ID" ] && [ "$PEER_ID" != "null" ]; then
      # the peer id obtained, break
      break
    fi
    # wait another 5 sec id the node is not ready yet
    sleep 5
  done
  # check if the peer id was obtained
  assert [ -n "$PEER_ID" ] || [ ! "$PEER_ID" == "null" ]

  # add authorize node
  run "$PYRSIA_CLI" authorize --peer "$PEER_ID"
  # check if the add authorize node successful
  assert_output --partial "successfully"
  sleep 5
}
