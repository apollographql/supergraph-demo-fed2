FROM node:17-bullseye

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY pandas.js .
COPY pandas.graphql .

CMD [ "node", "pandas.js" ]
