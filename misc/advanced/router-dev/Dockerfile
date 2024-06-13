FROM --platform=linux/amd64 rust:1.79 as build

ENV RUST_BACKTRACE=full

# create a new empty shell project
RUN USER=root cargo new --bin acme_router

WORKDIR /acme_router

# Update our build image and install required packages
RUN apt-get update -y \
    && apt-get install -y \
    protobuf-compiler \
    cmake

RUN rustup component add rustfmt

# copy over your manifests
COPY ./Cargo.toml ./Cargo.toml

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy your source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/acme_router*
RUN cargo build --release

RUN mkdir -p /dist/config && mkdir -p /dist/schema

# our final image uses distroless, which is more secure by default
#FROM --platform=linux/amd64 gcr.io/distroless/cc-debian11

# if you want bin/sh you'll want a distro that includes it instead
FROM --platform=linux/amd64 debian:bookworm-slim

RUN apt-get update -y \
    && apt-get install -y \
    ca-certificates \
    curl

# copy the build artifact from the build stage
COPY --from=build /dist /dist
COPY --from=build --chown=root:root /acme_router/target/release/acme_router /dist
COPY --from=build --chown=root:root /acme_router/Cargo.lock /dist

WORKDIR /dist

# for faster docker shutdown
STOPSIGNAL SIGINT

# set the startup command to run your binary
# note: if you want sh you can override the entrypoint using docker run -it --entrypoint=sh my-router-image
ENTRYPOINT ["./acme_router"]
