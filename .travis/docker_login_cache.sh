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
