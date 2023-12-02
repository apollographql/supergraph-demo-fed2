FROM node:21-bookworm-slim

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY users.js .
COPY users.graphql .

CMD [ "node", "users.js" ]
