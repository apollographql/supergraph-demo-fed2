FROM --platform=linux/amd64 debian:bullseye

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl 

WORKDIR /dist

COPY ./rhai/ rhai/

#RUN curl -ssL https://router.apollo.dev/download/nix/latest | sh -s -- v0.12.0-alpha-defer2
COPY ./install.sh .
RUN ./install.sh v0.12.1-alpha-defer2 x86_64-linux ./router 0.12.0


# for faster docker shutdown
STOPSIGNAL SIGINT

# set the startup command to run your binary
# note: if you want sh you can override the entrypoint using docker run -it --entrypoint=sh my-router-image
ENTRYPOINT ["./router"]

