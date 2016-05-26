FROM ubuntu:14.04
MAINTAINER hyunsun.moon@gmail.com

RUN apt-get update
RUN apt-get install -qy --no-install-recommends telnet build-essential gawk wget texinfo supervisor

# Patch Quagga to support FPM
ADD change.diff /tmp/change.diff
RUN wget http://download.savannah.gnu.org/releases/quagga/quagga-0.99.23.tar.gz
RUN tar zxvf quagga-0.99.23.tar.gz
RUN cd quagga-0.99.23 && patch -p1 < /tmp/change.diff
RUN cd quagga-0.99.23 && ./configure --enable-fpm --prefix=/usr
RUN cd quagga-0.99.23 && make
RUN cd quagga-0.99.23 && make install

# 179/tcp - bgp port
# 2601/tcp - zebra management port
# 2604/tcp - ospfd management port
# 2605/tcp - bgpd management port
EXPOSE 179 2601 2605

VOLUME /etc/quagga

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord"]
