FROM --platform=linux/amd64 debian:bullseye

WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y \
    libssl-dev \
    curl \
    jq

COPY install.sh .
RUN ./install.sh

STOPSIGNAL SIGINT

CMD [ "/usr/src/app/router", "-c", "/etc/config/configuration.yaml", "--log", "info" ]
