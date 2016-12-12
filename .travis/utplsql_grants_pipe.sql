whenever sqlerror  exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback on
set heading off
set verify off

define ut3_user       = &1

--object types
grant execute on ut_output_dbms_pipe to &ut3_user;
grant execute on ut_output_pipe_helper to &ut3_user;

