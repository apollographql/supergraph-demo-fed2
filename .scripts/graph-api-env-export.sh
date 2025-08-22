#!/bin/bash

# load defaults
if ls graph-api.env > /dev/null 2>&1; then
  eval "$(cat graph-api.env)"
else
  echo "run 'make publish-subgraphs' to set APOLLO_KEY and APOLLO_GRAPH_REF environment variables"
  exit 1
fi

export APOLLO_KEY=$APOLLO_KEY
export APOLLO_GRAPH_REF=$APOLLO_GRAPH_REF

#echo "key:$APOLLO_KEY"
#.echo "ref:$APOLLO_GRAPH_REF"
#export APOLLO_UPLINK_ENDPOINTS="https://aws.uplink.api.apollographql.com/, https://uplink.api.apollographql.com/"
