#!/bin/bash

set -e

echo -------------------------------------------------------------------------------------------
( set -x; cd examples/composition/local; ${ROVER_BIN:-'rover'} supergraph compose --config supergraph.localhost.yaml > supergraph.localhost.graphql)
( set -x; cd examples/composition/local; ${ROVER_BIN:-'rover'} supergraph compose --config supergraph.dockerhost.yaml > supergraph.dockerhost.graphql)
echo -------------------------------------------------------------------------------------------
