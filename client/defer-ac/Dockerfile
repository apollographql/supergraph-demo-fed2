FROM node:18-bullseye

WORKDIR /usr/src/app

COPY package.json .
COPY apollo-client-3.7.0-beta.6.tgz .

RUN npm install
RUN npm install apollo-client-3.7.0-beta.6.tgz

COPY public public
COPY src src

CMD [ "npm", "run", "start" ]
