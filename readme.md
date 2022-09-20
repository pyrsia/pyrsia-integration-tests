# Pyrsia Integration Tests
## Overview

The integration tests use the [Bats](https://github.com/bats-core/bats-core) framework. [Bats](https://github.com/bats-core/bats-core) is a TAP-compliant testing framework for Bash. It provides
a simple way to verify that the UNIX programs you write behave as expected. 

- $REPO_DIR - the folder where the tests repo was cloned.
- The tests are located in `$REPO_DIR/bats/tests`.
- List of the Bats dependencies used in the tests:

| BATS lib | path  | repository |
|----------|-------|------------|
| bats-core  | bats/lib/bats   | https://github.com/bats-core/bats-core.git |
| bats-support  | bats/lib/test_helper/bats-support | https://github.com/bats-core/bats-support.git |
| bats-assert  | bats/lib/test_helper/bats-assert   | https://github.com/bats-core/bats-assert.git |
| bats-files  | bats/lib/test_helper/bats-files   | https://github.com/bats-core/bats-assert.git |
- Supported platforms: Linux (x86), macOs (x86, m1), windows (WSL)
- Linter (github actions):  [SheelCheck](https://www.shellcheck.net)/[Shell Linter](https://github.com/azohra/shell-linter)
 
## How to set up and run the tests
 
Fetch the tests repository with the dependencies (the submodules are necessary to successfully execute the tests):

```sh
$ git clone --recurse-submodules https://github.com/pyrsia/pyrsia-integration-tests.git
```
 
Run the tests:
 
```sh
$ $REPO_DIR/bats/run_tests.sh
```
