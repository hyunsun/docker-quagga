#!/bin/bash

# Remove existing ONOS container
echo "Remove existing ONOS container"
sudo docker stop onos
sudo docker rm onos

# Set br-router bridge controller none
sudo ovs-vsctl set-controller br-router

# Run ONOS container
echo && echo "Run ONOS container"
sudo docker pull onosproject/onos
sudo docker run -t -d --name onos onosproject/onos

onos=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' 'onos')
curl="curl --user onos:rocks"
conf_url="http://$onos:8181/onos/v1/network/configuration"
app_url="http://$onos:8181/onos/v1/applications"

ssh-keygen -f "/home/$(whoami)/.ssh/known_hosts" -R [$onos]:8101
echo && echo "Wait for ONOS to start"
until $($curl -o /dev/null -s --fail -X POST $app_url/org.onosproject.drivers/active); do
    printf '.'
    sleep 5
done
echo "Done"

# Activate applications
echo && echo && echo "Activate ONOS apps"
$curl -X POST $app_url/org.onosproject.drivers/active
echo && $curl -sS -X POST $app_url/org.onosproject.openflow/active
echo && $curl -sS -X POST $app_url/org.onosproject.netcfghostprovider/active
echo && $curl -sS -X POST $app_url/org.onosproject.vrouter/active

# Push network config
echo && echo && echo "Push network-cfg.json"
$curl -X POST -H "Content-Type: application/json" $conf_url -d @network-cfg.json

# Set br-router bridge controller to ONOS
echo "Set controller of br-router to $onos"
sudo ovs-vsctl set-controller br-router tcp:$onos:6653
echo "Finished!"
