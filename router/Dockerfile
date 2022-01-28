FROM amd64/ubuntu:latest

WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y \ 
    libssl-dev \
    curl \
    jq

COPY install.sh .
RUN ./install.sh

CMD [ "/usr/src/app/router", "-c", "/etc/config/configuration.yaml", "-s", "/etc/config/supergraph.graphql", "--log", "info" ]
