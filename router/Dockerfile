from node:16-alpine

WORKDIR /usr/src/app

COPY package.json .

RUN npm install

COPY router.js .

CMD [ "node", "router.js" ]
