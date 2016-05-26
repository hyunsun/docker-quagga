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
PREFIX=$(echo $CONTAINER_IP_CIDR | cut -d'/' -f 2)
BRIDGE_NAME=${3:-br-ex}

# clean up existing container with same name and IP
sudo docker stop $CONTAINER_HOSTNAME
sudo docker rm $CONTAINER_HOSTNAME
sudo ovs-vsctl del-port quagga

cp ~/docker-quagga/volumes/quagga/zebra.conf.sample ~/docker-quagga/volumes/quagga/zebra.conf
sed -i 's/container-name/'$CONTAINER_HOSTNAME'/g' ~/docker-quagga/volumes/quagga/zebra.conf
sed -i 's/container-ip/'$CONTAINER_IP'/g' ~/docker-quagga/volumes/quagga/zebra.conf
sed -i 's/prefix/'$PREFIX'/g' ~/docker-quagga/volumes/quagga/zebra.conf

# BGP
cp ~/docker-quagga/volumes/quagga/bgpd.conf.sample ~/docker-quagga/volumes/quagga/bgpd.conf
sed -i 's/container-name/'$CONTAINER_HOSTNAME'/g' ~/docker-quagga/volumes/quagga/bgpd.conf
sed -i 's/container-ip/'$CONTAINER_IP'/g' ~/docker-quagga/volumes/quagga/bgpd.conf

# OSPF - OSPF is disable dy default
# you need to enable it in supervisord.conf
cp ~/docker-quagga/volumes/quagga/ospfd.conf.sample ~/docker-quagga/volumes/quagga/ospfd.conf
sed -i 's/container-name/'$CONTAINER_HOSTNAME'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
sed -i 's/container-ip/'$CONTAINER_IP'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
sed -i 's/prefix/'$PREFIX'/g' ~/docker-quagga/volumes/quagga/ospfd.conf

sudo docker run --net='none' --privileged --name $CONTAINER_HOSTNAME --hostname $CONTAINER_HOSTNAME -d -v ~/docker-quagga/volumes/quagga:/usr/etc quagga-fpm
sudo ~/docker-quagga/pipework $BRIDGE_NAME -i eth0 -l quagga $CONTAINER_HOSTNAME $CONTAINER_IP_CIDR
