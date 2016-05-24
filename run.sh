#!/bin/bash

if [[ -n "$1" ]]; then
    CONTAINER_HOSTNAME=$1
fi

docker network rm net-router
docker network create --subnet=172.18.0.0/16 net-router
docker run --privileged --name ${CONTAINER_HOSTNAME:-router} --hostname ${CONTAINER_HOSTNAME:-router} --net net-router --ip=172.18.0.100 -d -v ~/docker-quagga/volumes/quagga:/etc/quagga quagga
