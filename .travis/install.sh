#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"
set -ev
#install core of utplsql
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
pwd
set feedback off
set verify off

@../source/create_utplsql_owner.sql $UT3_OWNER $UT3_OWNER_PASSWORD $UT3_TABLESPACE
--only needed to run unit tests for utplsql v3, not required to run utplsql v3 itself
grant select any dictionary to $UT3_OWNER;

@../source/create_utplsql_owner.sql $UT3_USER $UT3_USER_PASSWORD $UT3_TABLESPACE
cd ..

--enable plsql debug
--cd development
--@ut_debug_enable.sql
--cd ..

cd source
@install.sql $UT3_OWNER
@create_synonyms_and_grants_for_user.sql $UT3_OWNER $UT3_USER
cd ..

cd development
conn $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR
@utplsql_style_check.sql

exit
SQL
