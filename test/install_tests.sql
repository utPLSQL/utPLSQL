set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

<<<<<<< HEAD
--Install helpers
@@helpers/ut_test_table.sql
@@helpers/ut_example_tests.pks
@@helpers/ut_example_tests.pkb
@@helpers/ut_without_body.pks
@@helpers/ut_with_invalid_body.pks
@@helpers/ut_with_invalid_body.pkb
@@helpers/other_dummy_object.tps
@@helpers/test_dummy_object.tps
@@helpers/test_dummy_object_list.tps

--Install tests
@@core.pks
@@api/test_ut_runner.pks
@@core/test_ut_utils.pks
@@core/test_ut_suite.pks
@@core/test_ut_test.pks
@@core/annotations/test_annotation_parser.pks
@@core/annotations/test_annotation_manager.pks
@@core/expectations/test_matchers.pks
@@core/test_output_buffer.pks
@@core/test_suite_manager.pks
@@core/reporters/test_coverage.pks
@@core/reporters/test_coverage/test_coverage_sonar_reporter.pks
@@core/reporters/test_coverage/test_coveralls_reporter.pks
@@core/reporters/test_xunit_reporter.pks
@@core/expectations.pks
@@core/expectations/scalar_data/binary/test_be_greater_or_equal.pks
@@core/expectations/scalar_data/binary/test_be_greater_than.pks
@@core/expectations/scalar_data/binary/test_be_less_or_equal.pks
@@core/expectations/scalar_data/binary/test_equal.pks
@@core/expectations/scalar_data/binary/test_expect_to_be_less_than.pks
@@core/expectations/compound_data/test_expect_to_be_empty.pks
@@core/expectations/compound_data/test_expect_to_have_count.pks
@@core/expectations/compound_data/test_expectations_cursor.pks
@@core/expectations/compound_data/test_expectation_anydata.pks
@@core/expectations/scalar_data/unary/test_expect_not_to_be_null.pks
@@core/expectations/scalar_data/unary/test_expect_to_be_not_null.pks
@@core/expectations/scalar_data/unary/test_expect_to_be_null.pks
@@core/expectations/scalar_data/unary/test_expect_to_be_true_false.pks
@@core/annotations/test_annot_throws_exception.pks

@@core.pkb
@@api/test_ut_runner.pkb
@@core/test_ut_utils.pkb
@@core/test_ut_suite.pkb
@@core/test_ut_test.pkb
@@core/annotations/test_annotation_parser.pkb
@@core/annotations/test_annotation_manager.pkb
@@core/expectations/test_matchers.pkb
@@core/test_output_buffer.pkb
@@core/test_suite_manager.pkb
@@core/reporters/test_coverage.pkb
@@core/reporters/test_coverage/test_coverage_sonar_reporter.pkb
@@core/reporters/test_coverage/test_coveralls_reporter.pkb
@@core/reporters/test_xunit_reporter.pkb
@@core/expectations.pkb
@@core/expectations/scalar_data/binary/test_be_greater_or_equal.pkb
@@core/expectations/scalar_data/binary/test_be_greater_than.pkb
@@core/expectations/scalar_data/binary/test_be_less_or_equal.pkb
@@core/expectations/scalar_data/binary/test_equal.pkb
@@core/expectations/scalar_data/binary/test_expect_to_be_less_than.pkb
@@core/expectations/compound_data/test_expect_to_be_empty.pkb
@@core/expectations/compound_data/test_expect_to_have_count.pkb
@@core/expectations/compound_data/test_expectations_cursor.pkb
@@core/expectations/compound_data/test_expectation_anydata.pkb
@@core/expectations/scalar_data/unary/test_expect_not_to_be_null.pkb
@@core/expectations/scalar_data/unary/test_expect_to_be_not_null.pkb
@@core/expectations/scalar_data/unary/test_expect_to_be_null.pkb
@@core/expectations/scalar_data/unary/test_expect_to_be_true_false.pkb
@@core/annotations/test_annot_throws_exception.pkb
=======
@core.pks
@ut_utils/test_ut_utils.pks
@ut_annotation_parser/test_annotation_parser.pks
@ut_matchers/test_matchers.pks
@ut_output_buffer/test_output_buffer.pks
@ut_suite_manager/test_suite_manager.pks
@@ut_reporters/test_coverage.pks
@@ut_reporters/test_coverage_sonar_reporter.pks
@@ut_reporters/test_coveralls_reporter.pks
@@ut_reporters/test_xunit_reporter.pks
@@ut_reporters/test_coverage_cob_reporter.pks
@ut_expectations/test_expectations_cursor.pks
@@ut_runner/test_ut_runner.pks
@@ut_annotation_manager/test_annotation_manager.pks

@core.pkb
@ut_utils/test_ut_utils.pkb
@ut_annotation_parser/test_annotation_parser.pkb
@ut_matchers/test_matchers.pkb
@ut_output_buffer/test_output_buffer.pkb
@ut_suite_manager/test_suite_manager.pkb
@@ut_reporters/test_coverage.pkb
@@ut_reporters/test_coverage_sonar_reporter.pkb
@@ut_reporters/test_coveralls_reporter.pkb
@@ut_reporters/test_xunit_reporter.pkb
@@ut_reporters/test_coverage_cob_reporter.pkb
@ut_expectations/test_expectations_cursor.pkb
@@ut_runner/test_ut_runner.pkb
@@ut_annotation_manager/test_annotation_manager.pkb
>>>>>>> Added Cob Reporter Tests

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
