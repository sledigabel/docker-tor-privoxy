FROM ubuntu:latest
MAINTAINER sledigabel <sledigabel@gmail.com>

# https://github.com/sledigabel/docker-tor-privoxy/

ENV TORNAME tor-0.3.1.9
ENV PRIVOXY privoxy_3.0.26-4_amd64

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y libwww-perl build-essential libevent-dev libssl-dev curl autoconf supervisor init-system-helpers logrotate ucf
RUN GET https://www.torproject.org/dist/${TORNAME}.tar.gz | tar xz -C /tmp
RUN GET http://archive.ubuntu.com/ubuntu/pool/universe/p/privoxy/${PRIVOXY}.deb > /tmp/${PRIVOXY}.deb

RUN dpkg -i /tmp/${PRIVOXY}.deb

# compiling & installing TOR
RUN cd /tmp/${TORNAME} && ./configure && make && make install
# deleting compilation dir
RUN rm -rf /tmp/${TORNAME}

# configuring
RUN echo "Log notice stdout" >> /etc/torrc
RUN echo "SocksPort 0.0.0.0:19150" >> /etc/torrc

# configuring privoxy
RUN sed -i 's/^listen-address \(.*\)$/#listen-address \1/' /etc/privoxy/config
RUN echo "listen-address 0.0.0.0:18118" >> /etc/privoxy/config
RUN echo "forward-socks5 / localhost:19150 ." >> /etc/privoxy/config
RUN echo "debug 512" >> /etc/privoxy/config

EXPOSE 18118

# supervisor config
ADD tor_proxy.conf /etc/supervisor/conf.d/tor_proxy.conf

CMD ["/usr/bin/supervisord"]
