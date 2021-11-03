#!/bin/bash 

echo "======================================="
echo "SUBGRAPH PUBLISH"
echo "======================================="

source "$(dirname $0)/subgraphs.sh"
source "$(dirname $0)/graph-api-env.sh"

for subgraph in ${subgraphs[@]}; do
  echo "---------------------------------------"
  echo "subgraph: ${subgraph}"
  echo "---------------------------------------"
  url="url_$subgraph"
  (set -x; ${ROVER_BIN:-'rover'} subgraph publish ${APOLLO_GRAPH_REF} --routing-url "${!url}" --schema subgraphs/${subgraph}/${subgraph}.graphql --name ${subgraph} --convert)
  echo ""
done
