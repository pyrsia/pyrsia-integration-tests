#!/usr/bin/env bash

# common setup
COMMON_SETUP='common-setup'
# docker compose file
DOCKER_COMPOSE_DIR="$REPO_DIR/bats/tests/resources/docker/docker-compose_single_node.yml"
# maven build service mapping ID
BUILD_SERVICE_MAVEN_MAPPING_ID="commons-codec:commons-codec:1.15"
BUILD_SERVICE_DOCKER_MAPPING_ID="alpine:3.16"

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
    PYRSIA_CLI="$PYRSIA_TARGET_DIR/pyrsia"
}

@test "Testing the build service, maven (build, inspect-log)." {
  # TODO This part is disabled because of 1032
  # the build request should fail on the non existing maven mapping ID
  # run run "$PYRSIA_CLI" build maven --gav "FAKE_MAVEN_MAPPING"
  # refute_output --partial  "successfully"
  echo -e "\t- WARNING: This test is partly disabled because of https://github.com/pyrsia/pyrsia/issues/1032" >&3
  # confirm the artifact is not already added to pyrsia node
  run "$PYRSIA_CLI" inspect-log maven --gav $BUILD_SERVICE_MAVEN_MAPPING_ID
  refute_output --partial $BUILD_SERVICE_MAVEN_MAPPING_ID

  # init the build
  run "$PYRSIA_CLI" build maven --gav $BUILD_SERVICE_MAVEN_MAPPING_ID
  assert_output --partial "successfully"

  # waiting until the build is done => inspect logs available
  echo -e "\t- Building $BUILD_SERVICE_MAVEN_MAPPING_ID, it might take a while..." >&3
  # shellcheck disable=SC2034
  for i in {0..40}
  do
    inspect_log=$($PYRSIA_CLI inspect-log maven --gav $BUILD_SERVICE_MAVEN_MAPPING_ID)
    if [[ "$inspect_log" == *"$BUILD_SERVICE_MAVEN_MAPPING_ID"* ]]; then
      break
    fi
    sleep 5
  done

  #check if the logs contains the artifact info
  run echo "$inspect_log"
  assert_output --partial $BUILD_SERVICE_MAVEN_MAPPING_ID
  echo -e "\t- Maven build successful - $BUILD_SERVICE_MAVEN_MAPPING_ID" >&3
}

@test "Testing the build service, docker (build docker image, inspect-log)." {
  # the build image request should fail on the non existing maven mapping ID
  run "$PYRSIA_CLI" build docker --image "FAKE_IMAGE_NAME"
  refute_output --partial  "successfully"

  # confirm the artifact is not already added to pyrsia node
  run "$PYRSIA_CLI" inspect-log docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID
  refute_output --partial $BUILD_SERVICE_DOCKER_MAPPING_ID

  # init the build
  run "$PYRSIA_CLI" build docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID
  assert_output --partial "successfully"

  # waiting until the build is done => inspect logs available
  echo -e "\t- Building docker image $BUILD_SERVICE_DOCKER_MAPPING_ID - [$PYRSIA_CLI build docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID], it might take a while..." >&3
  # shellcheck disable=SC2034
  for i in {0..40}
  do
    inspect_log=$($PYRSIA_CLI inspect-log docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID)
    if [[ "$inspect_log" == *"$BUILD_SERVICE_DOCKER_MAPPING_ID"* ]]; then
      break
    fi
    sleep 5
  done

  #check if the logs contains the artifact info
  run echo "$inspect_log"
  assert_output --partial $BUILD_SERVICE_DOCKER_MAPPING_ID
  echo -e "\t- Docker image built successfully - $BUILD_SERVICE_DOCKER_MAPPING_ID" >&3
}

