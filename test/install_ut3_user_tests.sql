set define off
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set plsql_optimize_level=0;

@@common_helper/utplsql.pks
@@common_helper/utplsql.pkb

prompt Install user tests
@@ut3_user/helpers/some_item.tps
@@ut3_user/helpers/some_items.tps
@@ut3_user/helpers/some_object.tps
@@ut3_user/test_user.pks
@@ut3_user/expectations.pks
@@ut3_user/expectations.pkb
@@ut3_user/expectations/unary/test_expect_not_to_be_null.pks
@@ut3_user/expectations/unary/test_expect_to_be_null.pks
@@ut3_user/expectations/unary/test_expect_to_be_empty.pks
@@ut3_user/expectations/unary/test_expect_to_have_count.pks
@@ut3_user/expectations/unary/test_expect_to_be_true_false.pks
@@ut3_user/expectations/unary/test_expect_to_be_not_null.pks
@@ut3_user/expectations/binary/test_equal.pks
@@ut3_user/expectations/binary/test_expect_to_be_less_than.pks
@@ut3_user/expectations/binary/test_be_less_or_equal.pks
@@ut3_user/expectations/binary/test_be_greater_or_equal.pks
@@ut3_user/expectations/binary/test_be_greater_than.pks
@@ut3_user/expectations/binary/test_to_be_within.pks
@@ut3_user/expectations/test_matchers.pks
@@ut3_user/expectations/test_expectation_anydata.pks
@@ut3_user/expectations/test_expectations_cursor.pks
set define on
@@install_above_12_1.sql 'ut3_user/expectations/test_expectations_json.pks'
set define off
@@ut3_user/api/test_ut_runner.pks
@@ut3_user/api/test_ut_run.pks
@@ut3_user/reporters.pks
@@ut3_user/reporters/test_tfs_junit_reporter.pks
@@ut3_user/reporters/test_teamcity_reporter.pks
@@ut3_user/reporters/test_sonar_test_reporter.pks
@@ut3_user/reporters/test_junit_reporter.pks
@@ut3_user/reporters/test_documentation_reporter.pks
@@ut3_user/reporters/test_debug_reporter.pks
@@ut3_user/reporters/test_realtime_reporter.pks
@@ut3_user/reporters/test_coverage.pks
set define on
@@install_above_12_1.sql 'ut3_user/reporters/test_extended_coverage.pks'
@@install_above_12_1.sql 'ut3_user/reporters/test_coverage/test_html_extended_reporter.pks'
set define off
@@ut3_user/reporters/test_coverage/test_coveralls_reporter.pks
@@ut3_user/reporters/test_coverage/test_cov_cobertura_reporter.pks
@@ut3_user/reporters/test_coverage/test_coverage_sonar_reporter.pks
set define on
@@install_below_12_2.sql 'ut3_user/reporters/test_proftab_coverage.pks'
@@install_below_12_2.sql 'ut3_user/reporters/test_coverage/test_html_proftab_reporter.pks'
set define off

@@ut3_user/test_user.pkb
@@ut3_user/expectations/unary/test_expect_not_to_be_null.pkb
@@ut3_user/expectations/unary/test_expect_to_be_null.pkb
@@ut3_user/expectations/unary/test_expect_to_be_empty.pkb
@@ut3_user/expectations/unary/test_expect_to_have_count.pkb
@@ut3_user/expectations/unary/test_expect_to_be_true_false.pkb
@@ut3_user/expectations/unary/test_expect_to_be_not_null.pkb
@@ut3_user/expectations/binary/test_equal.pkb
@@ut3_user/expectations/binary/test_expect_to_be_less_than.pkb
@@ut3_user/expectations/binary/test_be_less_or_equal.pkb
@@ut3_user/expectations/binary/test_be_greater_or_equal.pkb
@@ut3_user/expectations/binary/test_be_greater_than.pkb
@@ut3_user/expectations/binary/test_to_be_within.pkb
@@ut3_user/expectations/test_matchers.pkb
@@ut3_user/expectations/test_expectation_anydata.pkb
@@ut3_user/expectations/test_expectations_cursor.pkb
set define on
@@install_above_12_1.sql 'ut3_user/expectations/test_expectations_json.pkb'
set define off
@@ut3_user/api/test_ut_runner.pkb
@@ut3_user/api/test_ut_run.pkb
@@ut3_user/reporters.pkb
@@ut3_user/reporters/test_tfs_junit_reporter.pkb
@@ut3_user/reporters/test_teamcity_reporter.pkb
@@ut3_user/reporters/test_sonar_test_reporter.pkb
@@ut3_user/reporters/test_junit_reporter.pkb
@@ut3_user/reporters/test_documentation_reporter.pkb
@@ut3_user/reporters/test_debug_reporter.pkb
@@ut3_user/reporters/test_realtime_reporter.pkb
@@ut3_user/reporters/test_coverage.pkb
set define on
@@install_above_12_1.sql 'ut3_user/reporters/test_extended_coverage.pkb'
@@install_above_12_1.sql 'ut3_user/reporters/test_coverage/test_html_extended_reporter.pkb'
set define off
@@ut3_user/reporters/test_coverage/test_coveralls_reporter.pkb
@@ut3_user/reporters/test_coverage/test_cov_cobertura_reporter.pkb
@@ut3_user/reporters/test_coverage/test_coverage_sonar_reporter.pkb
set define on
@@install_below_12_2.sql 'ut3_user/reporters/test_proftab_coverage.pkb'
@@install_below_12_2.sql 'ut3_user/reporters/test_coverage/test_html_proftab_reporter.pkb'
set define off


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
