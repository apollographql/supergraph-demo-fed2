#!/bin/bash

echo "====================="
echo "Defer returns chunked responses without --compressed"
echo "====================="
( set -x; curl -i -X POST http://localhost:4000/ \
  -H 'accept: multipart/mixed; deferSpec=20220824, application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"operationName":"deferVariation","variables":{},"query":"query deferVariation { allProducts { ...MyFragment @defer sku id } } fragment MyFragment on Product { variation { name } }"}')
echo "----------------------"
printf "done.\n\n"
sleep 2

echo "====================="
echo "Defer returns chunked responses with --compressed"
echo "====================="
( set -x; curl --compressed -i -X POST http://localhost:4000/ \
  -H 'accept: multipart/mixed; deferSpec=20220824, application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"operationName":"deferVariation","variables":{},"query":"query deferVariation { allProducts { ...MyFragment @defer sku id } } fragment MyFragment on Product { variation { name } }"}')
echo "----------------------"
printf "done.\n\n"
sleep 2

echo "====================="
echo "Defer with trailing __typename without --compressed"
echo "====================="
( set -x; curl -i -X POST http://localhost:4000/ \
  -H 'accept: multipart/mixed; deferSpec=20220824, application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"operationName":"deferVariation","variables":{},"query":"query deferVariation { allProducts { ...MyFragment @defer sku id __typename } } fragment MyFragment on Product { variation { name __typename } __typename }"}')
echo "----------------------"
printf "done.\n\n"
sleep 2

echo "====================="
echo "Defer with trailing __typename with --compressed"
echo "====================="
( set -x; curl --compressed -i -X POST http://localhost:4000/ \
  -H 'accept: multipart/mixed; deferSpec=20220824, application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"operationName":"deferVariation","variables":{},"query":"query deferVariation { allProducts { ...MyFragment @defer sku id __typename } } fragment MyFragment on Product { variation { name __typename } __typename }"}')
echo "----------------------"
printf "done.\n\n"
sleep 2
