#!/bin/bash 

source "$(dirname $0)/graph-api-env.sh"

./router/custom-main/localhost/acme_router -c router/custom-main/localhost/router.yaml
