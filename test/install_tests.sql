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
@@helpers/other_dummy_object.tps
@@helpers/test_dummy_object.tps
@@helpers/test_dummy_object_list.tps

--Install tests
@@core.pks
@@api/test_ut_runner.pks
@@api/test_ut_run.pks
@@core/test_ut_utils.pks
@@core/test_ut_suite.pks
@@core/test_ut_test.pks
@@core/annotations/test_annotation_parser.pks
@@core/annotations/test_annotation_manager.pks
@@core/expectations/test_matchers.pks
@@core/test_output_buffer.pks
@@core/test_suite_manager.pks
@@core/reporters/test_coverage.pks
set define on
@@install_below_12_2.sql 'core/reporters/test_not_existing_block.pks'
@@install_below_12_2.sql 'core/reporters/test_not_existing_block.pkb'
set define off
set define on
@@install_above_12_1.sql 'core/reporters/test_block_coverage.pks'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_html_block_reporter.pks'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_coveralls_reporter_block.pks'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_coverage_sonar_rprt_blk.pks'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_cov_cobertura_rptr_blk.pks'
set define off
@@core/reporters/test_coverage/test_coverage_sonar_reporter.pks
@@core/reporters/test_coverage/test_coveralls_reporter.pks
@@core/reporters/test_coverage/test_cov_cobertura_reporter.pks
@@core/reporters/test_coverage/test_html_proftab_reporter.pks
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
@@api/test_ut_run.pkb
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
@@core/reporters/test_coverage/test_cov_cobertura_reporter.pkb
@@core/reporters/test_coverage/test_html_proftab_reporter.pkb
set define on
@@install_above_12_1.sql 'core/reporters/test_block_coverage.pkb'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_html_block_reporter.pkb'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_coveralls_reporter_block.pkb'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_coverage_sonar_rprt_blk.pkb'
@@install_above_12_1.sql 'core/reporters/test_coverage/test_cov_cobertura_rptr_blk.pkb'
set define off
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
