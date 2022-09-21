#!/usr/bin/env bash

# the tests temp dir
PYRSIA_TEMP_DIR=/tmp/pyrsia_tests/pyrsia
# the pyrsia binaries
PYRSIA_TARGET_DIR=$PYRSIA_TEMP_DIR/target/release
# check if the env clean up is enabled
if [ -z "$CLEAN_UP_TEST_ENVIRONMENT" ]; then
  # if "true" then the temp files (pyrsia sources, binaries, etc.) and the docker images/containers are destroyed in "teardown_file" method.
  CLEAN_UP_TEST_ENVIRONMENT=true
fi

_common_setup() {
  # load the bats "extensions"
  load '../lib/test_helper/bats-support/load'
  load '../lib/test_helper/bats-assert/load'
}

_common_setup_file() {
  echo "Setting up the test environment..." >&3
  local git_branch="main"
  # clone or update the sources
  if [ -d $PYRSIA_TEMP_DIR/.git ]; then
    git --git-dir=$PYRSIA_TEMP_DIR/.git fetch
    git --git-dir=$PYRSIA_TEMP_DIR/.git --work-tree=$PYRSIA_TEMP_DIR merge origin/main
  else
    mkdir -p $PYRSIA_TEMP_DIR
    git clone --branch $git_branch https://github.com/pyrsia/pyrsia.git $PYRSIA_TEMP_DIR
  fi

  echo "Building the Pyrsia CLI sources, it might take a while..." >&3
  echo "Pyrsia CLI source dir: $PYRSIA_TEMP_DIR" >&3
  cargo build --profile=release --package=pyrsia_cli --manifest-path=$PYRSIA_TEMP_DIR/Cargo.toml >&3
  echo "Building Pyrsia CLI completed!" >&3
  echo "Building the Pyrsia node docker image and starting the container, it might take a while..." >&3
  DOCKER_COMPOSE_PATH=$1;
  docker-compose -f "$DOCKER_COMPOSE_PATH" up -d >&3
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
  echo "" >&3
  if [ "$CLEAN_UP_TEST_ENVIRONMENT" = true ]; then
    echo "Tearing down the tests environment..." >&3
    echo "Cleaning up the docker images and containers..."  >&3
    docker-compose -f "$DOCKER_COMPOSE_PATH" down --rmi all >&3
  else
    echo "Stopping the docker containers..." >&3
    docker-compose -f "$DOCKER_COMPOSE_PATH" stop >&3
    echo "WARNING: The docker images/container was not removed because 'CLEAN_UP_TEST_ENVIRONMENT'=FALSE'"  >&3
  fi
  echo "Done tearing the tests environment!" >&3
}