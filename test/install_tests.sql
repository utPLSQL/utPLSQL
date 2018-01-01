set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

--Install helpers
@@helpers/ut_test_table.sql
@@helpers/ut_example_tests.pks
@@helpers/ut_example_tests.pkb
@@helpers/ut_without_body.pks
@@helpers/ut_with_invalid_body.pks
@@helpers/ut_with_invalid_body.pkb

--Install tests
@@core.pks
@@core/test_ut_utils.pks
@@core/annotations/test_annotation_parser.pks
@@core/test_matchers.pks
@@core/test_output_buffer.pks
@@core/test_suite_manager.pks
@@core/reporters/test_coverage.pks
@@core/reporters/test_coverage/test_coverage_sonar_reporter.pks
@@core/reporters/test_coverage/test_coveralls_reporter.pks
@@core/reporters/test_xunit_reporter.pks
@@core/expectations/test_expectations_cursor.pks
@@core/expectations/test_expect_not_to_be_null.pks
@@test_ut_runner.pks
@@core/annotations/test_annotation_manager.pks
@@core/test_ut_suite.pks
@@core/test_ut_test.pks

@@core.pkb
@@core/test_ut_utils.pkb
@@core/annotations/test_annotation_parser.pkb
@@core/test_matchers.pkb
@@core/test_output_buffer.pkb
@@core/test_suite_manager.pkb
@@core/reporters/test_coverage.pkb
@@core/reporters/test_coverage/test_coverage_sonar_reporter.pkb
@@core/reporters/test_coverage/test_coveralls_reporter.pkb
@@core/reporters/test_xunit_reporter.pkb
@@core/expectations/test_expectations_cursor.pkb
@@core/expectations/test_expect_not_to_be_null.pkb
@@test_ut_runner.pkb
@@core/annotations/test_annotation_manager.pkb
@@core/test_ut_suite.pkb
@@core/test_ut_test.pkb

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

exit
