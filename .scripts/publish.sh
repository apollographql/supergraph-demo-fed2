#!/bin/bash 

SUBGRAPH_PORTS="${1:default}"

echo "======================================="
echo "PUBLISH SUBGRAPHS TO APOLLO REGISTRY"
echo "======================================="

source "$(dirname $0)/subgraphs.sh"
source "$(dirname $0)/graph-api-env.sh"

for subgraph in ${subgraphs[@]}; do
  echo "---------------------------------------"
  echo "subgraph: ${subgraph}"
  echo "---------------------------------------"
  url="url_$subgraph"
  schema="schema_$subgraph"
  (set -x; ${ROVER_BIN:-'rover'} subgraph publish ${APOLLO_GRAPH_REF} --routing-url "${!url}" --schema "${!schema}" --name ${subgraph} --convert)
  echo ""
done
