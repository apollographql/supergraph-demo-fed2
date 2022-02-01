from node:17-alpine

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY products.js .
COPY products.graphql .

CMD [ "node", "products.js" ]
