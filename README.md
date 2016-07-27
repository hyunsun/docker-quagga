FPM enabled Quagga Docker image
https://hub.docker.com/r/hyunsun/quagga-fpm/

Here's an example command to bring up the container with quagga-fpm image.
```
#!/bin/bash

# Example command to run the container with quagga-fpm image
# Replace VOLUME with the path where your docker configs are
VOLUME=~/docker-quagga/volumes/quagga
sudo docker run --privileged --cap-add=NET_ADMIN --cap-add=NET_RAW -d -v $VOLUME:/etc/quagga hyunsun/quagga-fpm
```
