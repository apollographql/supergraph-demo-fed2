from amd64/ubuntu:latest

WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y \ 
    libssl-dev \
    curl \
    jq

COPY install.sh .
COPY run.sh .
RUN ./install.sh

CMD [ "/usr/src/app/run.sh" ]
