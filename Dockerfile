FROM ubuntu:14.04
MAINTAINER hyunsun.moon@gmail.com

RUN apt-get update
RUN apt-get install -qy --no-install-recommends supervisor quagga telnet

# 2601/tcp - zebra management port
# 2604/tcp - ospfd management port
EXPOSE 2601 2604

VOLUME /etc/quagga

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord"]
