#!/bin/bash

cd source
set -ev
#install core of utplsql
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
set verify off

@install_headless.sql $UT3_OWNER $UT3_OWNER_PASSWORD
SQL

"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback on
--needed for Mystats script to work
grant select any dictionary to $UT3_OWNER;
--Needed for testing a coverage outside ut3_owner.
grant create any procedure, drop any procedure, execute any procedure to $UT3_OWNER;

set feedback off
@create_utplsql_owner.sql $UT3_USER $UT3_USER_PASSWORD $UT3_TABLESPACE

conn $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR
@../development/utplsql_style_check.sql

exit
SQL
