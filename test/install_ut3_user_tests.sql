set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set plsql_optimize_level=0;

prompt Install user tests
@@ut3_user/expectations/binary/test_equal.pks
@@ut3_user/expectations/binary/test_expect_to_be_less_than.pks
@@ut3_user/expectations/binary/test_be_less_or_equal.pks
@@ut3_user/expectations/test_matchers.pks
@@ut3_user/expectations/test_expectation_anydata.pks
@@ut3_user/expectations/test_expectations_cursor.pks
@@ut3_user/api/test_ut_runner.pks

@@ut3_user/expectations/binary/test_equal.pkb
@@ut3_user/expectations/binary/test_expect_to_be_less_than.pkb
@@ut3_user/expectations/binary/test_be_less_or_equal.pkb
@@ut3_user/expectations/test_matchers.pkb
@@ut3_user/expectations/test_expectation_anydata.pkb
@@ut3_user/expectations/test_expectations_cursor.pkb
@@ut3_user/api/test_ut_runner.pkb

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
  
  for i in ( select object_name from user_objects t where t.object_type = 'PACKAGE')
  loop
    execute immediate 'grant execute on '||i.object_name||' to UT3_TESTER';
  end loop;
  
end;
/

exit;
