# Pyrsia Integration Tests
## Overview

The integration tests use the [Bats](https://github.com/bats-core/bats-core) framework. [Bats](https://github.com/bats-core/bats-core) is a TAP-compliant testing framework for Bash. It provides
a simple way to verify that the UNIX programs you write behave as expected.

- $REPO_DIR - the folder where the tests repo was cloned.
- The tests are located in `$REPO_DIR/bats/tests`.
- List of the Bats dependencies used in the tests:

| Bats lib     | path  | repository |
|--------------|-------|------------|
| bats-core    | bats/lib/bats   | https://github.com/bats-core/bats-core.git |
| bats-support | bats/lib/test_helper/bats-support | https://github.com/bats-core/bats-support.git |
| bats-assert  | bats/lib/test_helper/bats-assert   | https://github.com/bats-core/bats-assert.git |
| bats-files   | bats/lib/test_helper/bats-files   | https://github.com/bats-core/bats-assert.git |
- Supported platforms: Linux (x86), macOs (x86, m1), windows (WSL)
- Linter (github actions):  [SheelCheck](https://www.shellcheck.net)/[Shell Linter](https://github.com/azohra/shell-linter)

## How to set up and run the tests

Fetch the repository with the dependencies (the submodules are necessary to successfully execute the tests):

```sh
$ git clone --recurse-submodules https://github.com/pyrsia/pyrsia-integration-tests.git
```

Run the tests:

```sh
$ REPO_DIR=$REPO_DIR $REPO_DIR/bats/run_tests.sh
```

## Tests (scope)
1) Pyrsia CLI/connectivity related tests
   - Test 'pyrsia help' CLI, check if the help is shown.
   - Test 'pyrsia ping' CLI, check if the node is up and reachable.
   - Test 'pyrsia status' CLI, check if the node is connected to peers.
   - Test 'pyrsia list' CLI, check if the node returns the list of peers.
     - NOTE: temporarily disabled with timeout, problems with P2P and listing the peer nodes
   - Test 'pyrsia config' CLI, show the config and check the values
   - Test 'pyrsia version' CLI, check if the CLI version shows.
   - Test 'pyrsia build' help options CLI, check if the BUILD help is shown.
   - Test 'pyrsia inspect-log' help/options CLI, check if the INSPECT-LOG help is shown.
2) Pyrsia build service
   - Test the build service, MAVEN (build, inspect-log).
     - NOTE: This test is partly disabled because of https://github.com/pyrsia/pyrsia/issues/1032
   - Test the build service, DOCKER (build docker image, inspect-log)
3) Pyrsia P2P service, client side (project)
   - TBD
