#!/bin/bash

set -ev
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}/../../source

time "$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
whenever sqlerror exit failure rollback

--------------------------------------------------------------------------------
PROMPT Adding back create-trigger privilege to $UT3_DEVELOP_SCHEMA for testing
grant administer database trigger to $UT3_DEVELOP_SCHEMA;

--------------------------------------------------------------------------------
PROMPT Creating UT3_TESTER - Power-user for testing internal framework code

create user UT3_TESTER identified by "ut3" default tablespace $UT3_TABLESPACE quota unlimited on $UT3_TABLESPACE;
grant create session, create procedure, create type, create table to UT3_TESTER;

grant execute on dbms_lock to UT3_TESTER;

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


--------------------------------------------------------------------------------
PROMPT Creating UT3_USER - minimal privileges user for API testing

create user UT3_USER identified by "ut3" default tablespace $UT3_TABLESPACE quota unlimited on $UT3_TABLESPACE;
grant create session, create procedure, create type, create table to UT3_USER;

PROMPT Grants for starting a debugging session from UT3_USER
grant debug connect session to UT3_USER;
grant debug any procedure to UT3_USER;
begin
  \$if dbms_db_version.version <= 11 \$then
    null; -- no addition action necessary
  \$else
    -- necessary on 12c or higher
    dbms_network_acl_admin.append_host_ace (
      host =>'*',
      ace  => sys.xs\$ace_type(
                  privilege_list => sys.xs\$name_list('JDWP') ,
                  principal_name => 'UT3_USER',
                  principal_type => sys.xs_acl.ptype_db
              )
    );
  \$end
end;
/

--------------------------------------------------------------------------------
PROMPT Creating UT3_TESTER_HELPER - provides functions to allow min grant test user setup tests.

create user UT3_TESTER_HELPER identified by "ut3" default tablespace $UT3_TABLESPACE quota unlimited on $UT3_TABLESPACE;
grant create session, create procedure, create type, create table to UT3_TESTER_HELPER;

PROMPT Grants for testing distributed transactions
grant create public database link to UT3_TESTER_HELPER;
grant drop public database link to  UT3_TESTER_HELPER;

PROMPT Grants for testing coverage outside of main $UT3_DEVELOP_SCHEMA schema.
grant create any procedure, drop any procedure, execute any procedure, create any type, drop any type, execute any type, under any type,
  select any table, update any table, insert any table, delete any table, create any table, drop any table, alter any table,
  select any dictionary, create any synonym, drop any synonym,
  grant any object privilege, grant any privilege, create public synonym, drop public synonym, create any trigger
  to UT3_TESTER_HELPER;

grant create job to UT3_TESTER_HELPER;

PROMPT Additional grants for disabling DDL trigger and testing parser without trigger enabled/present

grant alter any trigger to UT3_TESTER_HELPER;
grant administer database trigger to UT3_TESTER_HELPER;
grant execute on dbms_lock to UT3_TESTER_HELPER;

create user ut3_cache_test_owner identified by ut3;
grant create session, create procedure to ut3_cache_test_owner;

create user ut3_no_extra_priv_user identified by ut3;
grant create session, create procedure to ut3_no_extra_priv_user;

create user ut3_select_catalog_user identified by ut3;
grant create session, create procedure, select_catalog_role to ut3_select_catalog_user;

create user ut3_select_any_table_user identified by ut3;
grant create session, create procedure, select any table to ut3_select_any_table_user;

create user ut3_execute_any_proc_user identified by ut3;
grant create session, create procedure, execute any procedure to ut3_execute_any_proc_user;
exit
SQL
