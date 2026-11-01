#!/bin/bash

set -ev

# Grants on $UT3_DEVELOP_SCHEMA needed for testing. Must be re-applied whenever $UT3_DEVELOP_SCHEMA is reinstalled.
time "$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
whenever sqlerror exit failure rollback

--------------------------------------------------------------------------------
PROMPT Adding back create-trigger privilege to $UT3_DEVELOP_SCHEMA for testing
grant administer database trigger to $UT3_DEVELOP_SCHEMA;

--------------------------------------------------------------------------------
PROMPT Granting $UT3_DEVELOP_SCHEMA code to UT3_TESTER

begin
  for i in (
    select object_name from all_objects t
      where t.object_type in ('PACKAGE','TYPE')
      and owner = '$UT3_DEVELOP_SCHEMA'
      and generated = 'N'
      and object_name not like 'SYS%')
  loop
    execute immediate 'grant execute on $UT3_DEVELOP_SCHEMA."'||i.object_name||'" to UT3_TESTER';
  end loop;
end;
/

PROMPT Granting $UT3_DEVELOP_SCHEMA tables to UT3_TESTER

begin
  for i in ( select table_name from all_tables t where  owner = '$UT3_DEVELOP_SCHEMA' and nested = 'NO' and iot_name is null)
  loop
    execute immediate 'grant select on $UT3_DEVELOP_SCHEMA.'||i.table_name||' to UT3_TESTER';
  end loop;
end;
/
exit
SQL
