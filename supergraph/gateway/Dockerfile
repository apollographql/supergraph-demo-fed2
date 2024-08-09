FROM node:20-bookworm-slim

WORKDIR /usr/src/app

COPY ./package.json .

RUN npm install

COPY ./gateway.js .

CMD [ "node", "gateway.js" ]
