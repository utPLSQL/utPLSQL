prompt Installing utplsql framework

whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

@@types/ut_object.tps
@@types/ut_objects_list.tps
@@types/ut_composite_object.tps
@@types/ut_executable.tps
@@types/ut_assert_result.tps
@@types/ut_assert_list.tps
@@ut_assert.pks
@@types/ut_reporter.tps
@@types/ut_reporters_list.tps
@@types/ut_composite_reporter.tps
@@types/ut_test_object.tps
@@types/ut_test.tps
@@types/ut_test_suite.tps
@@types/ut_reporter_decorator.tps
@@types/ut_dbms_output_suite_reporter.tps
@@ut_utils.pks
@@ut_metadata.pks
@@ut_suite_manager.pks

@@ut_utils.pkb
@@types/ut_assert_result.tpb
@@types/ut_reporter.tpb
@@types/ut_object.tpb
@@types/ut_composite_object.tpb
@@types/ut_test.tpb
@@types/ut_test_suite.tpb
@@types/ut_executable.tpb
@@types/ut_composite_reporter.tpb
@@types/ut_reporter_decorator.tpb
@@types/ut_dbms_output_suite_reporter.tpb
@@ut_metadata.pkb
@@ut_assert.pkb
@@ut_suite_manager.pkb


prompt Validating installation
select * from user_errors where name not like 'BIN$%' and name like 'UT\_%' escape '\';

declare
  l_cnt integer;
begin
  select count(1)
    into l_cnt
    from user_errors where name not like 'BIN$%' and name like 'UT\_%' escape '\';
  if l_cnt > 0 then
    raise_application_error(-20000, 'Not all sources were successfully installed.');
  end if;
end;
/

exit success
