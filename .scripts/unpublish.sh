#!/bin/bash

echo "======================================="
echo "SUBGRAPH UNPUBLISH"
echo "======================================="

source "$(dirname $0)/subgraphs.sh"
source "$(dirname $0)/graph-api-env.sh"

echo "" > unpublish.log
echo "subgraphs:"
for subgraph in ${subgraphs[@]}; do
  ( set -x; ${ROVER_BIN:-'rover'} subgraph delete ${APOLLO_GRAPH_REF} --name ${subgraph} --confirm 2>> unpublish.log )
done

if grep -Eq 'error:(.+) Graph has no implementing services' unpublish.log; then
  echo "Success, all subgraphs removed!"
  rm unpublish.log
  exit 0
else
  cat unpublish.log
  rm unpublish.log
  exit 1
fi
