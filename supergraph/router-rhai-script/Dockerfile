FROM --platform=linux/amd64 debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl 

WORKDIR /dist

COPY ./test.rhai supergraph/router-rhai-script/test.rhai

RUN curl -ssL https://router.apollo.dev/download/nix/latest | sh

# for faster docker shutdown
STOPSIGNAL SIGINT

# set the startup command to run the stock router binary
ENTRYPOINT ["./router"]

