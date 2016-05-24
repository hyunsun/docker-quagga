#!/bin/bash
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-get update

# remove the old
sudo apt-get purge lxc-docker*

# install the new
sudo apt-get install docker-engine
