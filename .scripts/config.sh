#!/bin/bash

source "$(dirname $0)/subgraphs.sh"

echo "subgraphs:"
for subgraph in ${subgraphs[@]}; do
  url="url_$subgraph"
  echo "  ${subgraph}:"
  echo "    routing_url: ${!url}"
  echo "    schema:"
  echo "      file: ./subgraphs/${subgraph}/${subgraph}.graphql"
done
