#!/bin/bash

set -ev
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}/../../source

time "$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
set feedback off
whenever sqlerror exit failure rollback

--------------------------------------------------------------------------------
PROMPT Creating UT3_TESTER - Power-user for testing internal framework code

create user UT3_TESTER identified by "ut3" default tablespace $UT3_TABLESPACE quota unlimited on $UT3_TABLESPACE;
grant create session, create procedure, create type, create table to UT3_TESTER;

# Editioning is enable on test users to validate that utPLSQL works well with editioned schema
alter user UT3_TESTER enable editions;

grant execute on dbms_lock to UT3_TESTER;


--------------------------------------------------------------------------------
PROMPT Creating UT3_USER - minimal privileges user for API testing

create user UT3_USER identified by "ut3" default tablespace $UT3_TABLESPACE quota unlimited on $UT3_TABLESPACE;
grant create session, create procedure, create type, create table to UT3_USER;

# Editioning is enable on test users to validate that utPLSQL works well with editioned schema
alter user UT3_USER enable editions;

PROMPT Grants for starting a debugging session from UT3_USER
grant debug connect session to UT3_USER;
grant debug any procedure to UT3_USER;
begin
  dbms_network_acl_admin.append_host_ace (
    host =>'*',
    ace  => sys.xs\$ace_type(
                privilege_list => sys.xs\$name_list('JDWP') ,
                principal_name => 'UT3_USER',
                principal_type => sys.xs_acl.ptype_db
            )
  );
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
  grant any object privilege, grant any privilege, create public synonym, drop public synonym, create any trigger, drop any trigger
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

"${SCRIPT_DIR}/create_test_grants.sh"
