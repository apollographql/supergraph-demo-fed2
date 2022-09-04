#!/bin/bash

set -e

echo -------------------------------------------------------------------------------------------
( set -x; ${ROVER_BIN:-'rover'} supergraph compose --config "$(dirname $0)/supergraph.yaml" > "$(dirname $0)/supergraph.graphql")
echo -------------------------------------------------------------------------------------------
