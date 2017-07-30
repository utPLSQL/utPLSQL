#!/bin/bash

cd source
set -ev

#additional privileges to run scripted tests
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback on
--needed for Mystats script to work
grant select any dictionary to $UT3_OWNER;
--Needed for testing a coverage outside ut3_owner.
grant create any procedure, drop any procedure, execute any procedure to $UT3_OWNER;

exit
SQL

#Create additional users
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
@create_utplsql_owner.sql $UT3_USER $UT3_USER_PASSWORD $UT3_TABLESPACE

exit
SQL