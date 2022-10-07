#!/usr/bin/env bash

# check if docker is running/installed.
if (! docker stats --no-stream ); then
  echo "Docker not found, please make sure Docker is installed and running!"
  exit 1
fi

if ! command -v jq &> /dev/null
then
    echo "'jq' is required and could not be found, please install 'jq'"
    exit
fi

# identify repo path
if [ -z "$REPO_DIR" ]; then
  echo "The REPO_DIR variable is not specified, Please provide the integration tests repository path (e.g. '$HOME/pyrsia-integration-tests')."
  exit 1
fi
# export repo path (used in the tests)
export REPO_DIR;

# start the tests
echo "Starting Pyrsia integration tests in $REPO_DIR..."
"$REPO_DIR"/bats/lib/bats/bin/bats "$REPO_DIR/bats/tests"
