#!/bin/bash 

SUBGRAPH_NETWORKING="${1:-localhost}"

>&2 echo ""
if [[ "$SUBGRAPH_NETWORKING" == "docker-compose" ]]; then
  >&2 echo "Subgraphs will listen on different docker-compose hostnames (all on port 4000)"
  source "$(dirname $0)/subgraphs/docker-compose-networking.sh"
else
  >&2 echo "Subgraphs will listen on different localhost ports (4001, 4002, ...)"
  source "$(dirname $0)/subgraphs/localhost-networking.sh"
fi
>&2 echo ""