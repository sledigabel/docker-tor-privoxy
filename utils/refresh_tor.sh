#!/bin/bash

# makes sure there's an image for tor ready to be kicked off
docker images | grep new-tor || exit 5

# makes sure there's a docker container currently running
docker ps -a | grep current_tor || exit 6

# stops the current instance
docker ps -a -f name=current_tor -q | xargs docker stop
docker ps -a -f name=current_tor -q | xargs docker rm

# restarts a new image
docker run -d -p 38118:18118 -v /var/log/privoxy:/var/log/privoxy --name='current_tor' new-tor
