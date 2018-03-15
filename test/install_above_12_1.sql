set termout off
set echo off
spool dummy.sql
prompt whenever sqlerror exit failure rollback
spool off


def FILE_NAME = '&&1'
column SCRIPT_NAME new_value SCRIPT_NAME noprint

VAR V_FILE_NAME VARCHAR2(1000);
begin
  if dbms_db_version.version = 12 and dbms_db_version.release >= 2
     or dbms_db_version.version > 12
  then
    :V_FILE_NAME := '&&FILE_NAME';
  else
    :V_FILE_NAME := 'dummy.sql';
  end if;
end;
/
set verify off
select :V_FILE_NAME as SCRIPT_NAME  from dual;
set termout on


@@&&SCRIPT_NAME

