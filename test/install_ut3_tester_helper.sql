set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set plsql_optimize_level=0;
--Install ut3_tester_helper
@@ut3_tester_helper/core.pks

@@ut3_tester_helper/core.pkb


grant execute on ut3_tester_helper.core to UT3$USER#;

set linesize 200
set define on
set verify off
column text format a100
column error_count noprint new_value error_count

prompt Validating installation

set heading on
select type, name, sequence, line, position, text, count(1) over() error_count
  from all_errors
 where owner = USER
   and name not like 'BIN$%'  --not recycled
   and name != 'UT_WITH_INVALID_BODY'
   -- errors only. ignore warnings
   and attribute = 'ERROR'
 order by name, type, sequence
/

begin
  if to_number('&&error_count') > 0 then
    raise_application_error(-20000, 'Not all sources were successfully installed.');
  else
    dbms_output.put_line('Installation completed successfully');
  end if;
end;
/

exit;
