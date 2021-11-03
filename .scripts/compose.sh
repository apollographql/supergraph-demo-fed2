#!/bin/bash

set -e

echo -------------------------------------------------------------------------------------------
( set -x; ${ROVER_BIN:-'rover'} fed2 supergraph compose --config ./supergraph.yaml > ./supergraph.graphql)
echo -------------------------------------------------------------------------------------------