#!/bin/bash

./router --version
./router -c /etc/config/configuration.yaml -s /etc/config/supergraph.graphql --log error
