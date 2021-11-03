#!/bin/bash

docker kill $(docker ps -aq)
docker rm $(docker ps -aq)
docker volume rm $(docker volume ls -qf dangling=true)
