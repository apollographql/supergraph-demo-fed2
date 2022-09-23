#!/bin/bash

PORT="${1:-4000}"

read -r -d '' QUERY <<"EOF"
{
  allProducts {
    id,
    name,
    sku,
    createdBy {
      email
    }
  }
}
EOF

QUERY=$(echo "${QUERY}" | awk -v ORS= -v OFS= '{$1=$1}1')

echo -------------------------------------------------------------------------------------------
( set -x; curl -i -X POST http://localhost:$PORT \
  -H 'Content-Type: application/json' \
  --data-raw '{ "query": "'"${QUERY}"'" }' )
echo
echo -------------------------------------------------------------------------------------------