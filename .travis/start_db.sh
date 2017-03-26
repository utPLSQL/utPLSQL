#!/bin/bash
set -e

DOCKER_BASE_TAG="viniciusam/oracledb"

# Private Repo Login
if [ ! -f $CACHE_DIR/.docker/config.json ]; then
    docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"
    mkdir -p $CACHE_DIR/.docker && cp $HOME/.docker/config.json $CACHE_DIR/.docker/
else
    echo "Using docker login from cache..."
    mkdir -p $HOME/.docker && cp $CACHE_DIR/.docker/config.json $HOME/.docker/
fi

docker pull $DOCKER_BASE_TAG:$ORACLE_VERSION
docker run -d --name $ORACLE_VERSION $DOCKER_OPTIONS -p 1521:1521 $DOCKER_BASE_TAG:$ORACLE_VERSION
docker logs -f $ORACLE_VERSION | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered

if [ "$ORACLE_VERSION" == "12c-se2-r2" ]; then
    "$SQLCLI" sys/oracle@//127.0.0.1:1521/ORCLCDB as sysdba <<EOF
CREATE PLUGGABLE DATABASE ORCLPDB1 ADMIN USER PDBADMIN IDENTIFIED BY "$ORACLE_PWD"
  FILE_NAME_CONVERT=('/opt/oracle/oradata/ORCLCDB/pdbseed/','/opt/oracle/oradata/ORCLPDB1/');
ALTER PLUGGABLE DATABASE ORCLPDB1 SAVE STATE;  
ALTER PLUGGABLE DATABASE ORCLPDB1 OPEN READ WRITE;
ALTER SESSION SET CONTAINER = ORCLPDB1;
CREATE TABLESPACE users DATAFILE '/opt/oracle/oradata/ORCLPDB1/users01.dbf' SIZE 1M AUTOEXTEND ON NEXT 1M;
exit;
EOF
fi