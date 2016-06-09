#!/bin/bash

if [ -z "$1" ]
  then
    echo "Container hostname is required"
    echo "Usage: run.sh [hostname] [ETH1 IP address] [ETH1 MAC address]"
    exit 0
fi

if [ -z "$2" ]
  then
    echo "IP address for eth1 is required"
    echo "Usage: run.sh [hostname] [ETH1 IP address] [ETH1 MAC address]"
    exit 0
fi

if [ -z "$3" ]
  then
    echo "MAC address for eth1 is required"
    echo "Usage: run.sh [hostname] [ETH1 IP address] [ETH1 MAC address]"
    exit 0
fi

CONTAINER_HOSTNAME=$1
ETH1_IP_CIDR=$2
ETH1_MAC=$3
BRIDGE_NAME=${4:-br-ex}

# clean up existing container with same name and IP
sudo docker stop $CONTAINER_HOSTNAME
sudo docker rm $CONTAINER_HOSTNAME
sudo ovs-vsctl del-port quagga

sudo docker run --privileged --cap-add=NET_ADMIN --cap-add=NET_RAW --name $CONTAINER_HOSTNAME --hostname $CONTAINER_HOSTNAME -d -v ~/docker-quagga/volumes/quagga:/usr/etc hyunsun/quagga-fpm
sudo ~/docker-quagga/pipework $BRIDGE_NAME -i eth1 -l quagga $CONTAINER_HOSTNAME $ETH1_IP_CIDR $ETH1_MAC
#sudo docker exec -d $CONTAINER_HOSTNAME iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
