FROM ubuntu:latest
MAINTAINER sledigabel <sledigabel@gmail.com>

# https://github.com/sledigabel/docker-tor-privoxy/

ENV TORNAME tor-0.2.5.9-rc
ENV PRIVOXY privoxy_3.0.21-7_amd64

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y libwww-perl build-essential libevent-dev libssl-dev curl autoconf supervisor
RUN GET https://www.torproject.org/dist/${TORNAME}.tar.gz | tar xz -C /tmp
RUN GET http://archive.ubuntu.com/ubuntu/pool/universe/p/privoxy/${PRIVOXY}.deb > /tmp/${PRIVOXY}.deb

# installing privoxy
ENV INIT_SYSTEM init-system-helpers_1.20ubuntu3_all
RUN GET http://fr.archive.ubuntu.com/ubuntu/pool/main/i/init-system-helpers/${INIT_SYSTEM}.deb > /tmp/${INIT_SYSTEM}.deb
RUN dpkg -i /tmp/${INIT_SYSTEM}.deb
RUN dpkg -i /tmp/${PRIVOXY}.deb

# compiling & installing TOR
RUN cd /tmp/${TORNAME} && ./configure && make && make install
# deleting compilation dir
RUN rm -rf /tmp/${TORNAME}

# configuring
RUN echo "Log notice stdout" >> /etc/torrc
RUN echo "SocksPort 0.0.0.0:9150" >> /etc/torrc

# configuring privoxy
RUN sed -i 's/^listen-address .*$/listen-address 0.0.0.0:8118/' /etc/privoxy/config
RUN echo "forward-socks5 / localhost:9150 ." >> /etc/privoxy/config
RUN echo "forward thetvdb.com ." >> /etc/privoxy/config
RUN echo "forward .thetvdb.com ." >> /etc/privoxy/config
RUN echo "debug 9903" >> /etc/privoxy/config

EXPOSE 8118

# supervisor config
ADD tor_proxy.conf /etc/supervisor/conf.d/tor_proxy.conf

CMD ["/usr/bin/supervisord"]
