FROM ubuntu:14.04
MAINTAINER hyunsun.moon@gmail.com

RUN apt-get update
RUN apt-get install -qy --no-install-recommends supervisor quagga telnet

# 179/tcp  - bgp port
# 2601/tcp - zebra management port
# 2605/tcp - bgpd management port
EXPOSE 179 2601 2605

VOLUME /etc/quagga

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord"]
