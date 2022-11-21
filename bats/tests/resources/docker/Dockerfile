# syntax=docker/dockerfile:1.4.1

FROM rust:1.62-buster AS node_with_build_service
WORKDIR /src
ENV RUST_BACKTRACE=1
ENV DEV_MODE=onapt
ARG GIT_BRANCH
ARG GIT_REPO
RUN apt-get update && apt-get install -y -q
RUN apt-get install build-essential libssl-dev cmake pkg-config jq openjdk-11-jdk maven jq -y -q
RUN git clone https://github.com/tiainen/pyrsia_build_pipeline_prototype.git
WORKDIR /src/pyrsia_build_pipeline_prototype
RUN PATH="$HOME/.cargo/bin:$PATH" RUST_LOG=debug cargo build -q --workspace
WORKDIR /src
COPY entrypoint_bootstrap_node.sh entrypoint_no_bootstrap_node.sh entrypoint_auth_node.sh ./
RUN chmod +x ./*.sh
RUN git clone --branch $GIT_BRANCH $GIT_REPO
WORKDIR /src/pyrsia
RUN PATH="$HOME/.cargo/bin:$PATH" RUST_LOG=debug cargo build -q --package=pyrsia_node
