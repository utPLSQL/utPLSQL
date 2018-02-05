#!/bin/bash

cd source
set -ev
#install core of utplsql
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
set verify off

alter session set plsql_warnings = 'ENABLE:ALL', 'DISABLE:(5004,5018,6000,6001,6003,6009,6010,7206)';
@install_headless.sql $UT3_OWNER $UT3_OWNER_PASSWORD
SQL

#additional privileges to run scripted tests
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback on
--needed for Mystats script to work
grant select any dictionary to $UT3_OWNER;
--Needed for testing a coverage outside ut3_owner.
grant create any procedure, drop any procedure, execute any procedure to $UT3_OWNER;

conn $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR
@../development/utplsql_style_check.sql
exit
SQL

#Create additional users
"$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
@create_utplsql_owner.sql $UT3_TESTER $UT3_TESTER_PASSWORD $UT3_TABLESPACE

set feedback on
--Needed for testing coverage outside of main UT3 schema.
grant create any procedure, drop any procedure, execute any procedure, create any type, drop any type, execute any type, under any type, select any table, update any table, insert any table, delete any table, create any table, drop any table, alter any table, select any dictionary to $UT3_TESTER;
exit
SQL
