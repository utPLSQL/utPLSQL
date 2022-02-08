#!/bin/bash

set -ev
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}/../../source

time "$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
    set feedback off
    set verify off
    whenever sqlerror exit failure rollback

    @uninstall_all.sql $UT3_DEVELOP_SCHEMA
SQL
time "$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
    set feedback off
    set verify off
    whenever sqlerror exit failure rollback
    declare
      v_leftover_objects_count integer;
    begin
      select sum(cnt)
        into v_leftover_objects_count
        from (
          select count(1) cnt from dba_objects where owner = '$UT3_DEVELOP_SCHEMA'
           where object_name not like 'PLSQL_PROFILER%' and object_name not like 'DBMSPCC_%'
          union all
          select count(1) cnt from dba_synonyms where table_owner = '$UT3_DEVELOP_SCHEMA'
           where table_name not like 'PLSQL_PROFILER%' and table_name not like 'DBMSPCC_%'
        );
      if v_leftover_objects_count > 0 then
        raise_application_error(-20000, 'Not all objects were successfully uninstalled - leftover objects count='||v_leftover_objects_count);
      end if;
    end;
    /
    drop user $UT3_DEVELOP_SCHEMA cascade;
SQL
