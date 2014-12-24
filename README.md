# Docker TOR-PROXY

Docker container providing a HTTP proxy over TOR
Spins up an instance of TOR and PRIVOXY (http proxy forwarding to SOCKS).

## Building the docker image

```
$ git clone git@github.com:sledigabel/docker-tor-privoxy.git
$ cd docker-tor-privoxy
$ docker build -t tor-proxy .
```

## Running the container

```
$ docker run -d -p 8118:8118 --name tor-proxy tor-proxy
```

## Using the container

Point your browser to using a HTTP Proxy on <dockerhost>:8118
You can also test your proxy with a CLI util like curl like this:
```
curl -x <dockerhost>:8118 http://google.com
```

## Stopping the container

```
$ docker stop tor-proxy
```
