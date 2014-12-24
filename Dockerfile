FROM ubuntu:latest
MAINTAINER sledigabel <sledigabel@gmail.com>

# https://github.com/sledigabel/docker-tor-privoxy/

ENV TORNAME tor-0.2.5.10
ENV PRIVOXY privoxy_3.0.21-2_amd64

RUN apt-get update
RUN apt-get install -y libwww-perl build-essential libevent-dev libssl-dev curl autoconf supervisor
RUN GET https://www.torproject.org/dist/${TORNAME}.tar.gz | tar xz -C /tmp
RUN GET http://archive.ubuntu.com/ubuntu/pool/universe/p/privoxy/${PRIVOXY}.deb > /tmp/${PRIVOXY}.deb

# installing privoxy
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
RUN echo "debug 1" >> /etc/privoxy/config

EXPOSE 8118

# supervisor config
ADD tor_proxy.conf /etc/supervisor/conf.d/tor_proxy.conf

CMD ["/usr/bin/supervisord"]
