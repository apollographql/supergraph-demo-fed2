from node:16-alpine

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY pandas.js .
COPY pandas.graphql .

CMD [ "node", "pandas.js" ]
