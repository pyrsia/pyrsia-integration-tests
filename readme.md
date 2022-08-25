# Pyrsia Integration Tests
## Overview
 
$REPO_DIR - the folder where the tests repo was cloned.
 
## How to set up and run the tests
 
Fetch the tests repository (with submodules, unstable dev branch):

```sh
$ git clone --recurse-submodules -b  karolh200/integration-tests  https://github.com/karolh2000/pyrsia-integration-tests.git
```
 
Run the tests:
 
```sh
$ $REPO_DIR/bats/run_tests.sh
```
