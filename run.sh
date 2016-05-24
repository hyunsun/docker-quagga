#!/bin/bash

if [[ -n "$1" ]]; then
    CONTAINER_HOSTNAME=$1
fi

sudo docker network rm net-router
sudo docker network create --subnet=172.18.0.0/16 net-router
sudo docker run --privileged --name ${CONTAINER_HOSTNAME:-router} --hostname ${CONTAINER_HOSTNAME:-router} --net net-router --ip=172.18.0.101 -d -v ~/docker-quagga/volumes/quagga:/etc/quagga quagga
