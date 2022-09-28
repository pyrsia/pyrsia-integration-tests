#!/bin/bash

# start the build service
cd /src/pyrsia_build_pipeline_prototype || exit 1
RUST_LOG=debug cargo run &

# start the pyrsia node (no bootstrap, single node)
chmod +x /src/pyrsia/target/debug/pyrsia_node
RUST_LOG=pyrsia=debug /src/pyrsia/target/debug/pyrsia_node --host 0.0.0.0 --listen /ip4/0.0.0.0/tcp/44000 --pipeline-service-endpoint http://localhost:8080 --listen-only true
