#!/bin/bash

if [[ -n "$1" ]]; then
    CONTAINER_HOSTNAME=$1
fi

if [[ -n "$2" ]]; then
    CONTAINER_IP=$2
fi

sudo docker run --net='none' --privileged --name ${CONTAINER_HOSTNAME:-router} --hostname ${CONTAINER_HOSTNAME:-router} -d -v ~/docker-quagga/volumes/quagga:/etc/quagga quagga
sudo ~/docker-quagga/pipework ovsbr0 -i eth0 ${CONTAINER_HOSTNAME:-router} ${CONTAINER_IP:-192.168.100.254/24}
