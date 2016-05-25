#!/bin/bash

if [ -z "$1" ]
  then
    echo "Container hostname is required"
    echo "Usage: run.sh [hostname] [IP address]"
    exit 0
fi

if [ -z "$2" ]
  then
    echo "Container IP address is required"
    echo "Usage: run.sh [hostname] [IP address]"
    exit 0
fi

CONTAINER_HOSTNAME=$1
CONTAINER_IP_CIDR=$2
CONTAINER_IP=$(echo $CONTAINER_IP_CIDR | cut -d'/' -f 1)

cp ~/docker-quagga/volumes/quagga/bgpd.conf.sample ~/docker-quagga/volumes/quagga/bgpd.conf
sed -i 's/container-ip/'${CONTAINER_IP}'/g' ~/docker-quagga/volumes/quagga/bgpd.conf

sudo docker run --net='none' --privileged --name $CONTAINER_HOSTNAME --hostname $CONTAINER_HOSTNAME -d -v ~/docker-quagga/volumes/quagga:/etc/quagga quagga
sudo ~/docker-quagga/pipework br-ex -i eth0 $CONTAINER_HOSTNAME $CONTAINER_IP_CIDR
