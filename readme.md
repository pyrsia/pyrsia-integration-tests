# Pyrsia Integration Tests

## Overview

The integration tests use the [Bats](https://github.com/bats-core/bats-core) framework. [Bats](https://github.com/bats-core/bats-core) is a TAP-compliant testing framework for Bash. It provides
a simple way to verify that the UNIX programs you write behave as expected.

- $REPO_DIR - the folder where the tests repo was cloned.
- The tests are located in `$REPO_DIR/bats/tests`.
- List of the Bats dependencies used in the tests:

| Bats lib     | path                              | repository                                      |
|--------------|-----------------------------------|-------------------------------------------------|
| bats-core    | bats/lib/bats                     | <https://github.com/bats-core/bats-core.git>    |
| bats-support | bats/lib/test_helper/bats-support | <https://github.com/bats-core/bats-support.git> |
| bats-assert  | bats/lib/test_helper/bats-assert  | <https://github.com/bats-core/bats-assert.git>  |

- Supported platforms: Linux (x86), macOs (x86, m1), windows (WSL)
- Linter (github actions):  [ShellCheck](https://www.shellcheck.net)/[Shell Linter](https://github.com/azohra/shell-linter)

## How to set up and run the tests

Fetch the repository with the dependencies (the submodules are necessary to successfully execute the tests):

```sh
git clone --recurse-submodules https://github.com/pyrsia/pyrsia-integration-tests.git
```

In case you forgot to set `--recurse-submodules` during `clone` you can run the following command for the same effect:

```sh
git submodule update --init
```

Prerequisite: 
- Ensure that docker daemon is running and [JQ](https://stedolan.github.io/jq/) is installed.
- Ensure the pyrsia config contains the values shown below (show pyrsia config - `pyrsia config --show`):

```
host = 'localhost'
port = '7888'
disk_allocated = '10 GB'
```

Run the tests:

```sh
REPO_DIR=<path to your integration tests repo> $REPO_DIR/bats/run_tests.sh
```

Optional variables for `run_tests.sh` script:
- `GIT_REPO=<git repository URL>`, default value: `https://github.com/pyrsia/pyrsia.git`
- `GIT_BRANCH=<branch repository name>`, default value: `main`

## Tests (scope)

1) Pyrsia CLI/connectivity related tests
   - Test 'pyrsia help' CLI, check if the help is shown.
   - Test 'pyrsia ping' CLI, check if the node is up and reachable.
   - Test 'pyrsia status' CLI, check if the node is connected to peers.
   - Test 'pyrsia list' CLI, check if the node returns the list of peers.
   - Test 'pyrsia config' CLI, check if the config can be changed with valid values and shown.
   - Test 'pyrsia version' CLI, check if the CLI version shows.
   - Test 'pyrsia build' help options CLI, check if the build help is shown.
   - Test 'pyrsia inspect-log' help/options CLI, check if the inspect-log help is shown.
   - Test 'pyrsia authorize' help/options CLI, check if the authorize help is shown.
2) Pyrsia build service
   - Test the build service, MAVEN (build, inspect-log) (DISABLED)
   - Test the build service, DOCKER (build docker image, inspect-log).

## Clean up tests environment

The docker containers and images created by the tests framework are removed when CLEAN_UP_TEST_ENVIRONMENT=true (default).
The docker images and containers have to be removed manually if CLEAN_UP_TEST_ENVIRONMENT=false. The Pyrsia integration
tests also create the temp directory `/tmp/pyrsia_tests`which is not removed by the tests framework and if necessary has to be removed
manually.

Note: `CLEAN_UP_TEST_ENVIRONMENT=false` is not recommended because it impacts the tests environment and can lead to random failures. 

## Troubleshooting

In case of any problems with the tests environment reset the environment as follows:
1) Remove all docker images and containers:
   ```sh
      docker system prune --all
   ```
2) Remove the integration tests temp directory:
   ```sh
      rm -rf /tmp/pyrsia_tests/
   ```

## Tests logger

Supported logging levels:
- INFO (default)
- DEBUG
- ERROR

How to use logger in the tests:

```sh
  # load the test from the library
  load '../lib/logger/load'
  
  # print logging messages
  log INFO  "Info test message!"
  log DEBUG "Debug test message!"
  log ERROR "Error test message!"
```

How to start the tests with a different logging level (e.g DEBUG):

```sh
  TEST_LOG_LEVEL=<log level e.g DEBUG> REPO_DIR=<path to your integration tests repo> $REPO_DIR/bats/run_tests.sh
```

