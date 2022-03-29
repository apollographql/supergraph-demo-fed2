FROM node:16-bullseye

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY gateway.js .

CMD [ "node", "gateway.js" ]
