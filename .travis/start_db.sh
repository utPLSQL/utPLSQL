#!/bin/bash
set -e

# Oracle 12c R1 SE
if [ $ORACLE_VERSION = $ORACLE_12cR1SE ]; then
    docker login -u "$DOCKER_12cR1SE_USER" -p "$DOCKER_12cR1SE_PASS"
    docker pull viniciusam/oracle-12c-r1-se
    docker run -d --name $ORACLE_VERSION -p 1521:1521 viniciusam/oracle-12c-r1-se
    docker logs -f $ORACLE_VERSION | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered
    docker exec $ORACLE_VERSION ./createPDB.sh
fi

# Oracle 11g R2 XE
if [ $ORACLE_VERSION = $ORACLE_11gR2XE ]; then
    docker login -u "$DOCKER_11gR2XE_USER" -p "$DOCKER_11gR2XE_PASS"
    docker pull vavellar/oracle-11g-r2-xe
    docker run -d --name $ORACLE_VERSION --shm-size=1g -p 1521:1521 vavellar/oracle-11g-r2-xe    
    docker logs -f $ORACLE_VERSION | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered
    docker exec $ORACLE_VERSION ./setPassword.sh $ORACLE_PWD
fi
