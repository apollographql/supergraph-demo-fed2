#!/usr/bin/env bash

set -e

docker build -t supergraph-demo-fed2_apollo-router router/. --no-cache
