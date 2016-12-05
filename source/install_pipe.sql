prompt Installing utplsql framework - DBMS_PIPE additions

set serveroutput on size unlimited
set timing off
set define off

ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL', 'DISABLE:(6000,6001,6003,6010, 7206)';


whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

--common utilities

--core types
@@core/ut_output_pipe_helper.pks
@@core/types/ut_output_dbms_pipe.tps

--core type bodies
@@core/ut_output_pipe_helper.pkb
@@core/types/ut_output_dbms_pipe.tpb



set linesize 200
column text format a100
prompt Validating installation
-- erors only. ignore warnings
select name, type, sequence, line, position, text
 from user_errors
where name not like 'BIN$%'  --not recycled
and (name like 'UT%' or name in ('BE_FALSE','BE_LIKE','BE_NOT_NULL','BE_NULL','BE_TRUE','EQUAL','MATCH','BE_BETWEEN')) -- utplsql objects
and attribute = 'ERROR'
/

declare
  l_cnt integer;
begin
  select count(1)
    into l_cnt
    from user_errors
	where name not like 'BIN$%'
    and (name like 'UT%' or name in ('BE_FALSE','BE_LIKE','BE_NOT_NULL','BE_NULL','BE_TRUE','EQUAL','MATCH','BE_BETWEEN'))
    and attribute = 'ERROR';
  if l_cnt > 0 then
    raise_application_error(-20000, 'Not all sources were successfully installed.');
  end if;
end;
/

exit success
