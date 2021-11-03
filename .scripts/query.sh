#!/bin/bash

PORT="${1:-4000}"

read -r -d '' QUERY <<"EOF"
{
  allProducts {
    id,
    sku,
    createdBy {
      email,
      totalProductsCreated
    }
  }
}
EOF

QUERY=$(echo "${QUERY}" | awk -v ORS= -v OFS= '{$1=$1}1')

echo -------------------------------------------------------------------------------------------
ACT=$(set -x; curl -X POST -H 'Content-Type: application/json' --data '{ "query": "'"${QUERY}"'" }' http://localhost:$PORT/)
echo ""
echo "Result:"
echo "$ACT"
echo -------------------------------------------------------------------------------------------
