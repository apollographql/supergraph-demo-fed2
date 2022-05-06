FROM --platform=linux/amd64 rust:1.60 as build

ENV NODE_VERSION=16.13.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

ENV RUST_BACKTRACE=full

# create a new empty shell project
RUN USER=root cargo new --bin acme_router

WORKDIR /acme_router

RUN rustup component add rustfmt

# copy over your manifests
COPY ./Cargo.lock ./Cargo.lock
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
FROM --platform=linux/amd64 gcr.io/distroless/cc-debian11

# if you want bin/sh you'll want a distro that includes it instead
#FROM --platform=linux/amd64 debian:bullseye

# copy the build artifact from the build stage
COPY --from=build /dist /dist
COPY --from=build --chown=root:root /acme_router/target/release/acme_router /dist

WORKDIR /dist

# for faster docker shutdown
STOPSIGNAL SIGINT

# set the startup command to run your binary
# note: if you want sh you can override the entrypoint using docker run -it --entrypoint=sh my-router-image
ENTRYPOINT ["./acme_router"]

