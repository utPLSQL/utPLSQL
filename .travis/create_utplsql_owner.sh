#!/bin/bash
set -ev

#create user
"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
set echo off
@@$(dirname "$(readlink -f "$0")")/create_utplsql_owner.sql $UT3_OWNER $UT3_OWNER_PASSWORD $UT3_OWNER_TABLESPACE
SQL
