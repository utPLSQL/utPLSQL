#!/bin/bash
set -ev

cd $(dirname "$(readlink -f "$0")")
#create user
"$SQLCLI" -L -S sys/oracle@//$CONTAINER_IP:1521/ORCLCDB AS SYSDBA <<SQL
set echo off
@@create_utplsql_owner.sql $UT3_OWNER $UT3_OWNER_PASSWORD $UT3_OWNER_TABLESPACE
SQL
