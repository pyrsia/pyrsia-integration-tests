#!/usr/bin/env bash

COMMON_SETUP='common-setup'

DOCKER_COMPOSE_DIR="$REPO_DIR/bats/tests/resources/docker/docker-compose_bootstrap.yml"

# Individual tests should timeout after 3 minutes
export BATS_TEST_TIMEOUT=60

setup_file() {
  load $COMMON_SETUP
  _common_setup_file "$DOCKER_COMPOSE_DIR"
}

teardown_file() {
  load $COMMON_SETUP
  _common_teardown_file
}

setup() {
  load $COMMON_SETUP
  _common_setup
  PYRSIA_CLI="$PYRSIA_TARGET_DIR"/pyrsia
}

teardown() {
  run "$PYRSIA_CLI" config edit --host localhost --port 7888 --diskspace "10 GB"
}

@test "Testing 'pyrsia help' CLI, check if the help is shown." {
  # run pyrsia help
  run "$PYRSIA_CLI" help
  # check if pyrsia help is shown
  assert_output --partial 'USAGE:'
  assert_output --partial 'OPTIONS:'
  assert_output --partial 'SUBCOMMANDS:'

  # run pyrsia help
  run "$PYRSIA_CLI" -h
  # check if pyrsia help is shown
  assert_output --partial 'USAGE:'
  assert_output --partial 'OPTIONS:'
  assert_output --partial 'SUBCOMMANDS:'
}

@test "Testing 'pyrsia ping' CLI, check if the node is up and reachable." {
  # run pyrsia ping
  run "$PYRSIA_CLI" ping
  # check if pyrsia ping returns errors
  refute_output --partial 'Error'
}

@test "Testing 'pyrsia status' CLI, check if the node is connected to peers." {
  # run pyrsia status
  run "$PYRSIA_CLI" status
  # check if pyrsia node has peers, fail if doesn't or error
  refute_output --partial '0'
  refute_output --partial 'Error'
}

@test "Testing 'pyrsia list' CLI, check if the node returns the list of peers." {
  # run pyrsia list
  run "$PYRSIA_CLI" list
  # Fail if the list is empty or error
  refute_output --partial '[]'
  refute_output --partial 'Error'

  # run pyrsia list
  run "$PYRSIA_CLI" -l
  # Fail if the list is empty or error
  refute_output --partial '[]'
  refute_output --partial 'Error'
}

@test "Testing 'pyrsia config' CLI, check if the config can be changed and shown." {
  # change hostname
  run "$PYRSIA_CLI" config edit --host host.for.test
  assert_output --partial 'Node configuration Saved'

  # change port
  run "$PYRSIA_CLI" config -e --port 9999
  assert_output --partial 'Node configuration Saved'

  # change diskspace
  run "$PYRSIA_CLI" -c edit --diskspace "5 GB"
  assert_output --partial 'Node configuration Saved'

  run "$PYRSIA_CLI" config --show
  assert_output --partial 'host.for.test'
  assert_output --partial '9999'
  assert_output --partial '5 GB'

  # change two or more values at once
  run "$PYRSIA_CLI" -c -e --host 192.168.0.0 --port 8888 --diskspace "3 GB"
  assert_output --partial 'Node configuration Saved'

  run "$PYRSIA_CLI" -c --show
  assert_output --partial '192.168.0.0'
  assert_output --partial '8888'
  assert_output --partial '3 GB'

}

@test "Testing 'pyrsia config edit' CLI, check if input values are validated." {
  run "$PYRSIA_CLI" config edit --host .some.localhost --port 65536 --diskspace "10GB"
  assert_output --partial 'Invalid value for Hostname'
  assert_output --partial 'Invalid value for Port Number'
  assert_output --partial 'Invalid value for Disk Allocation'
}

@test "Testing 'pyrsia version', check if the CLI version shows." {
  # run pyrsia version
  run "$PYRSIA_CLI" --version
  # check if the CLI version shows
  assert_output --partial 'pyrsia_cli'

  # run pyrsia version
  run "$PYRSIA_CLI" -V
  # check if the CLI version shows
  assert_output --partial 'pyrsia_cli'
}

@test "Testing 'pyrsia build' help options, check if the build help is shown." {
  # run pyrsia build help
  run "$PYRSIA_CLI" build
  # check if the BUILD help is shown
  assert_output --partial 'docker'
  assert_output --partial 'maven'

  # run pyrsia build help
  run "$PYRSIA_CLI" -b
  # check if the BUILD help is shown
  assert_output --partial 'docker'
  assert_output --partial 'maven'

  # run pyrsia build help
  run "$PYRSIA_CLI" -b -h
  # check if the BUILD help is shown
  assert_output --partial 'docker'
  assert_output --partial 'maven'
}

@test "Testing 'pyrsia inspect-log' help/options, check if the inspect-log help is shown." {
  # run pyrsia inspect log help
  run "$PYRSIA_CLI" inspect-log -h
  # check if the INSPECT-LOG help is shown
  assert_output --partial 'docker'
  assert_output --partial 'maven'

  run "$PYRSIA_CLI" inspect-log
  # check if the INSPECT-LOG help is shown
  assert_output --partial 'docker'
  assert_output --partial 'maven'
}

@test "Testing 'pyrsia authorize' help/options, check if the authorize help is shown." {
  # run pyrsia authorize log help
  run "$PYRSIA_CLI" authorize -h
  # check if the authorize help is shown
  assert_output --partial 'peer'

  run "$PYRSIA_CLI" authorize
  # check if the authorize help is shown
  assert_output --partial 'peer'
}
