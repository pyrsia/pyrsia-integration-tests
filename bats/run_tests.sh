#!/usr/bin/env bash
#Open Docker, only if is not running
if (! docker stats --no-stream ); then
  echo "Docker not found, please make sure Docker is installed and running!"
  exit 1
fi
echo "Starting Pyrsia integration tests..."
./lib/bats/bin/bats ./tests
echo "Done!"
