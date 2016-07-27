FPM enabled Quagga Docker image
https://hub.docker.com/r/hyunsun/quagga-fpm/

Here's an example command to bring up the container with quagga-fpm image.
Replace VOLUME to where the Quagga config files are located.
```
$ export VOLUME=~/docker-quagga/volumes/quagga
$ sudo docker run --privileged -d -v $VOLUME:/etc/quagga hyunsun/quagga-fpm
```
