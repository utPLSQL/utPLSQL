#!/bin/bash

set -ev

#create user
"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
@@install/create_utplsql_user.sql ut3 ut3 users
SQL

cd source
#install core of utplsql
"$ORACLE_HOME/bin/sqlplus" ut3/ut3 @install.sql
