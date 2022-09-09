FROM node:18-bullseye

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY public public
COPY src src

CMD [ "npm", "run", "start" ]
