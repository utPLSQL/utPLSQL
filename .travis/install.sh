#!/bin/bash

set -ev
echo "$(dirname "$(readlink -f "$0")")"
#create user
"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
set echo off
@@$(dirname "$(readlink -f "$0")")/create_utplsql_user.sql ut3 ut3 users
SQL

cd source
#install core of utplsql
"$ORACLE_HOME/bin/sqlplus" ut3/ut3 @install.sql
