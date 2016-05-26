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
SERIAL_IP_CIDR=$2
SERIAL_IP=$(echo $SERIAL_IP_CIDR | cut -d'/' -f 1)
SERIAL_PREFIX=$(echo $SERIAL_IP_CIDR | cut -d'/' -f 2)

if [ -n "$3" ]
  then
    INTERNAL_IP_CIDR=$3
    INTERNAL_IP=$(echo $INTERNAL_IP_CIDR | cut -d'/' -f 1)
    INTERNAL_PREFIX=$(echo $INTERNAL_IP_CIDR | cut -d'/' -f 2)
fi

# clean up existing container with same name and IP
sudo docker stop $CONTAINER_HOSTNAME
sudo docker rm $CONTAINER_HOSTNAME
sudo ovs-vsctl del-port $SERIAL_IP
if [ -n $INTERNAL_IP ]
  then
    sudo ovs-vsctl del-port $INTERNAL_IP
fi

cp ~/docker-quagga/volumes/quagga/zebra.conf.sample ~/docker-quagga/volumes/quagga/zebra.conf
sed -i 's/container-name/'$CONTAINER_HOSTNAME'/g' ~/docker-quagga/volumes/quagga/zebra.conf
sed -i 's/serial-ip/'$SERIAL_IP'/g' ~/docker-quagga/volumes/quagga/zebra.conf
sed -i 's/serial-prefix/'$SERIAL_PREFIX'/g' ~/docker-quagga/volumes/quagga/zebra.conf

cp ~/docker-quagga/volumes/quagga/ospfd.conf.sample ~/docker-quagga/volumes/quagga/ospfd.conf
sed -i 's/container-name/'$CONTAINER_HOSTNAME'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
sed -i 's/serial-ip/'$SERIAL_IP'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
sed -i 's/serial-prefix/'$SERIAL_PREFIX'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
if [ -n $INTERNAL_IP ]
  then
    sed -i 's/! network internal-ip/  network '$INTERNAL_IP'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
    sed -i 's/internal-prefix/'$INTERNAL_PREFIX'/g' ~/docker-quagga/volumes/quagga/ospfd.conf
fi

if [ -n $INTERNAL_IP ]
  then
    sudo docker run --net='none' --net='none' --privileged --name $CONTAINER_HOSTNAME --hostname $CONTAINER_HOSTNAME -d -v ~/docker-quagga/volumes/quagga:/etc/quagga quagga
    sudo ~/docker-quagga/pipework br-ex -i eth0 -l $SERIAL_IP $CONTAINER_HOSTNAME $SERIAL_IP_CIDR
    sudo ~/docker-quagga/pipework br-router -i eth1 -l $INTERNAL_IP $CONTAINER_HOSTNAME $INTERNAL_IP_CIDR
  else
    sudo docker run --net='none' --privileged --name $CONTAINER_HOSTNAME --hostname $CONTAINER_HOSTNAME -d -v ~/docker-quagga/volumes/quagga:/etc/quagga quagga
    sudo ~/docker-quagga/pipework br-ex -i eth0 -l $SERIAL_IP $CONTAINER_HOSTNAME $SERIAL_IP_CIDR
fi
