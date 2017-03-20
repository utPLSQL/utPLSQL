#!/bin/bash
set -e

DOCKER_BASE_TAG="viniciusam/oracledb"

# Private Repo Login
if [ ! -f $CACHE_DIR/config.json ]; then
    docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"
    mkdir -p $CACHE_DIR/.docker && cp $HOME/.docker/config.json $CACHE_DIR/.docker/
else
    mkdir -p $HOME/.docker && cp $CACHE_DIR/.docker/config.json $HOME/.docker/
fi

# Oracle 12c R1 SE
if [ "$ORACLE_VERSION" == "$ORACLE_12cR1SE" ]; then
    docker pull $DOCKER_BASE_TAG:$ORACLE_12cR1SE
    docker run -d --name $ORACLE_VERSION -p 1521:1521 $DOCKER_BASE_TAG:$ORACLE_12cR1SE
    docker logs -f $ORACLE_VERSION | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered
fi

# Oracle 11g R2 XE
if [ "$ORACLE_VERSION" == "$ORACLE_11gR2XE" ]; then
    docker pull $DOCKER_BASE_TAG:$ORACLE_11gR2XE
    docker run -d --name $ORACLE_VERSION --shm-size=1g -p 1521:1521 $DOCKER_BASE_TAG:$ORACLE_11gR2XE
    docker logs -f $ORACLE_VERSION | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered
fi
