#!/bin/bash

echo ---------------------------------------------------------------
rover info
echo ---------------------------------------------------------------
which ./router
echo "Router $(./router --version)"
echo ---------------------------------------------------------------
which docker
echo "$(docker --version)"
echo ---------------------------------------------------------------
which docker-compose
echo "docker-compose: $(docker-compose --version)"
echo "docker compose: $(docker compose version)"
echo ---------------------------------------------------------------