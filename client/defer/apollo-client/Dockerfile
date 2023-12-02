FROM node:21-bookworm-slim

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY public public
COPY src src

CMD [ "npm", "run", "start" ]
