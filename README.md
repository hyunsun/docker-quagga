FPM enabled Quagga Docker image
https://hub.docker.com/r/hyunsun/quagga-fpm/

Here's an example command to bring up the container with quagga-fpm image.
Replace VOLUME to where the Quagga config files are.
```
sudo docker run --privileged --cap-add=NET_ADMIN --cap-add=NET_RAW -d -v [VOLUME]:/etc/quagga hyunsun/quagga-fpm
```
