#!/bin/bash 

SUBGRAPH_PORTS="${1:default}"

echo "======================================="
echo "SUBGRAPH PUBLISH"
echo "======================================="

echo ""
if [[ "$SUBGRAPH_PORTS" == "localhost" ]]; then
  echo "Subgraphs to listen on different localhost ports (4001, 4002, ...)"
  source "$(dirname $0)/subgraphs-localhost.sh"
else
  echo "Subgraphs to listen on different docker-compose DNS names (all on port 4000)"
  source "$(dirname $0)/subgraphs.sh"
fi
echo ""

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
