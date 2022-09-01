#!/bin/bash

echo "====================="
echo "Defer returns chunked responses without --compressed"
echo "====================="
(set -x; curl -i -X POST -H "Content-Type: application/json" -H "apollographql-client-name: smoke-test" -H "accept:multipart/mixed; deferSpec=20220824, application/json" --data '{ "query": "query deferVariation { allProducts { ...MyFragment @defer sku, id } } fragment MyFragment on Product { variation { name } }", "operationName": "deferVariation" }' http://localhost:4000/)
echo "----------------------"
printf "done.\n\n\n"
sleep 5

echo "====================="
echo "Defer with --compressed should return chunked responses"
echo "====================="
(set -x; curl --compressed -i -X POST -H "Content-Type: application/json" -H "apollographql-client-name: smoke-test" -H "accept:multipart/mixed; deferSpec=20220824, application/json" --data '{ "query": "query deferVariation { allProducts { ...MyFragment @defer sku, id } } fragment MyFragment on Product { variation { name } }", "operationName": "deferVariation" }' http://localhost:4000/)
echo "----------------------"
echo "done."
