#!/bin/bash
set -e

# Private Repo Login
if [ ! -f $CACHE_DIR/.docker/config.json ]; then
    docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"
    mkdir -p $CACHE_DIR/.docker && cp $HOME/.docker/config.json $CACHE_DIR/.docker/
else
    echo "Using docker login from cache..."
    mkdir -p $HOME/.docker && cp $CACHE_DIR/.docker/config.json $HOME/.docker/
fi

time docker pull $DOCKHER_HUB_REPO:$ORACLE_VERSION
time docker run -d --name $ORACLE_VERSION $DOCKER_OPTIONS -p 1521:1521 $DOCKHER_HUB_REPO:$ORACLE_VERSION
time docker logs -f $ORACLE_VERSION | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered
