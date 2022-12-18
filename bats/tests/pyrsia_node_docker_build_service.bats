#!/usr/bin/env bash

# common setup
COMMON_SETUP='common-setup'
# docker compose file
DOCKER_COMPOSE_DIR="$REPO_DIR/bats/tests/resources/docker/docker-compose_auth_nodes.yml"
# docker image tag info
NODE_DOCKER_IMAGE_NAME="alpine"
NODE_DOCKER_IMAGE_TAG="3.16"
NODE_DOCKER_IMAGE_OTHER_TAG="3.15"
# docker mapping id
BUILD_SERVICE_DOCKER_MAPPING_ID="$NODE_DOCKER_IMAGE_NAME:$NODE_DOCKER_IMAGE_TAG"
BUILD_SERVICE_DOCKER_MAPPING_OTHER_ID="$NODE_DOCKER_IMAGE_NAME:$NODE_DOCKER_IMAGE_OTHER_TAG"
# node_hostname
NODE_HOSTNAME="localhost:7889"
CLIENT_HOSTNAME="localhost:7888"

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

@test "Testing the build service, docker (build and download docker image, inspect-log)." {
  # the build image request should fail on the non existing maven mapping ID and non authorized node (node authorization is done later in the code)
  run "$PYRSIA_CLI" build docker --image "FAKE_IMAGE_NAME"
  refute_output --partial  "successfully"

  # get peer_id of node
  _get_peer_id_of_node "$NODE_HOSTNAME"
  # add authorize node
  run "$PYRSIA_CLI" authorize --peer "$PEER_ID"
  # check if the add authorize node successful
  assert_output --partial "successfully"

  # confirm the artifact is not already added to pyrsia node
  run "$PYRSIA_CLI" inspect-log docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID
  refute_output --partial $BUILD_SERVICE_DOCKER_MAPPING_ID

  # init the build
  local build_message
  build_message=$("$PYRSIA_CLI" build docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID)
  local build_id
  build_id=$(echo "$build_message" | awk -F\" '{ print $2 }')
  run echo "$build_message"
  assert_output --partial "successfully"

  # waiting until the build is done => inspect logs available
  echo -e "\t- Building docker image $BUILD_SERVICE_DOCKER_MAPPING_ID - [$PYRSIA_CLI build docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID], it might take a while..." >&3
  # shellcheck disable=SC2034
  for i in {0..40}
  do
    inspect_log=$($PYRSIA_CLI inspect-log docker --image $BUILD_SERVICE_DOCKER_MAPPING_ID)
    if [[ "$inspect_log" == *"$BUILD_SERVICE_DOCKER_MAPPING_ID"* ]]; then
      sleep 10
      # check if build status is present and SUCCESS
      log INFO "Check build status for build ID $build_id"
      run $PYRSIA_CLI build status --id $build_id
      assert_output --partial "SUCCESS"
      break
    fi
    sleep 5
  done

  # check if the logs contains the artifact info
  run echo "$inspect_log"
  assert_output --partial $BUILD_SERVICE_DOCKER_MAPPING_ID
  echo -e "\t- Docker image built successfully - $BUILD_SERVICE_DOCKER_MAPPING_ID" >&3

  # check if the built image can be pulled from the Pyrsia node
  local image_exists=false;
  # shellcheck disable=SC2034
  for i in {0..20}
  do
    # query the registry
    # shellcheck disable=SC2155
    local result=$(curl --silent http://$CLIENT_HOSTNAME/v2/library/$NODE_DOCKER_IMAGE_NAME/manifests/$NODE_DOCKER_IMAGE_TAG/)

    if ! [[ $result == *error* ]]; then
      image_exists=true
      break
    fi

    sleep 5
  done

  assert $image_exists
}

@test "No build status is returned when build id does not exist." {
  local build_id="b024a136-9021-42a1-b8de-c665c94470f4"
  run "$PYRSIA_CLI" build status --id $build_id
  assert_output --partial "Build status for '$build_id' was not found"
}

@test "Verify that a node can't be authorized twice." {
  # get peer_id of node
  _get_peer_id_of_node "$NODE_HOSTNAME"

  # try to authorize again
  run "$PYRSIA_CLI" authorize --peer "$PEER_ID"
  assert_output --partial "Authorize request failed with error: HTTP status error (400 Bad Request) for url (http://${CLIENT_HOSTNAME}/authorized_node)"
}

@test "Verify that a build starts if an artifact is requested but doesn't exist in the transparency log yet." {
  # request an image from the Pyrsia node that hasn't been built yet
  local image_exists=false;
  local URL=http://$CLIENT_HOSTNAME/v2/library/$NODE_DOCKER_IMAGE_NAME/manifests/$NODE_DOCKER_IMAGE_OTHER_TAG/
  # shellcheck disable=SC2155
  local result=$(curl -sS $URL)
  run echo "$result"
  assert_output --partial "ManifestUnknown"
  sleep 10

  # shellcheck disable=SC2034
  for i in {0..20}
  do
    # query the registry
    # shellcheck disable=SC2155
    result=$(curl --silent $URL)

    if ! [[ $result == *error* ]]; then
      image_exists=true
      break
    fi

    sleep 5
  done

  assert $image_exists

  # confirm the artifact is already added to pyrsia node
  run "$PYRSIA_CLI" inspect-log docker --image $BUILD_SERVICE_DOCKER_MAPPING_OTHER_ID
  assert_output --partial $BUILD_SERVICE_DOCKER_MAPPING_OTHER_ID
}
