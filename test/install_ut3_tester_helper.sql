set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set plsql_optimize_level=0;
--Install ut3_tester_helper
@@ut3_tester_helper/test_dummy_object.tps
@@ut3_tester_helper/other_dummy_object.tps
@@ut3_tester_helper/test_dummy_object_list.tps
@@ut3_tester_helper/test_tab_varchar2.tps
@@ut3_tester_helper/test_tab_varray.tps
@@ut3_tester_helper/test_dummy_number.tps
@@ut3_tester_helper/ut_test_table.sql
@@ut3_tester_helper/test_event_object.tps
@@ut3_tester_helper/test_event_list.tps

@@ut3_tester_helper/main_helper.pks
@@ut3_tester_helper/run_helper.pks
@@ut3_tester_helper/coverage_helper.pks
@@ut3_tester_helper/expectations_helper.pks
@@ut3_tester_helper/ut_example_tests.pks

@@ut3_tester_helper/main_helper.pkb
@@ut3_tester_helper/run_helper.pkb
@@ut3_tester_helper/coverage_helper.pkb
@@ut3_tester_helper/expectations_helper.pkb
@@ut3_tester_helper/ut_example_tests.pkb

@@ut3_tester_helper/annotation_cache_helper.pks
@@ut3_tester_helper/annotation_cache_helper.pkb
create or replace synonym ut3_tester.annotation_cache_helper for ut3_tester_helper.annotation_cache_helper;
create or replace synonym ut3$user#.coverage_helper for ut3_tester_helper.coverage_helper;

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
 
  for i in ( select object_name from user_objects t where t.object_type in ('PACKAGE','TYPE'))
  loop
    execute immediate 'grant execute on '||i.object_name||' to PUBLIC';
  end loop;
  
end;
/

exit;
