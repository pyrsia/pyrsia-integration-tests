#!/bin/bash

# start the build service
cd /src/pyrsia_build_pipeline_prototype || exit 1
RUST_LOG=debug cargo run &

# start the authorize node with the build service
RUST_LOG=pyrsia=debug /src/pyrsia/target/debug/pyrsia_node -p 7889 --host 0.0.0.0 --pipeline-service-endpoint http://localhost:8080 --listen /ip4/0.0.0.0/tcp/44001 --listen-only true
