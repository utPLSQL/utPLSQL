prompt Installing utplsql framework

set serveroutput on size unlimited
set timing off
set define off

spool install.log
ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL', 'DISABLE:(6000,6001,6003,6010, 7206)';


whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

--common utilities
@@core/types/ut_varchar2_list.tps
@@core/types/ut_clob_list.tps
@@core/ut_utils.pks
@@core/ut_metadata.pks
@@core/ut_utils.pkb
@@core/ut_metadata.pkb

--core types
@@core/types/ut_assert_result.tps
@@core/types/ut_assert_results.tps
@@core/types/ut_output.tps
@@core/types/ut_output_dbms_output.tps
@@core/types/ut_output_stream.tps
@@core/ut_output_pipe_helper.pks
@@core/types/ut_output_dbms_pipe.tps
@@core/types/ut_suite_item.tps
@@core/types/ut_suite_items.tps
@@core/types/ut_listener_interface.tps
@@core/types/ut_executable.tps
@@core/types/ut_test.tps
@@core/types/ut_suite.tps
@@core/types/ut_run.tps
@@core/types/ut_reporter.tps
@@core/types/ut_reporters.tps
@@core/types/ut_execution_listener.tps
--annoations
@@core/annotations/ut_annotations.pks
@@core/annotations/ut_annotations.pkb

--suite manager
@@core/ut_suite_manager.pks
@@core/ut_suite_manager.pkb
--test runner
@@core/ut_runner.pks
@@core/ut_runner.pkb

--assertios execution state interface
@@core/ut_assert_processor.pks
@@core/ut_assert_processor.pkb

--core type bodies
@@core/types/ut_suite_item.tpb
@@core/types/ut_test.tpb
@@core/types/ut_suite.tpb
@@core/types/ut_run.tpb
@@core/types/ut_execution_listener.tpb
@@core/types/ut_assert_result.tpb
@@core/types/ut_output.tpb
@@core/types/ut_output_dbms_output.tpb
@@core/types/ut_output_stream.tpb
@@core/ut_output_pipe_helper.pkb
@@core/types/ut_output_dbms_pipe.tpb
@@core/types/ut_reporter.tpb
@@core/types/ut_executable.tpb

--expecations and matchers
@@expectations/data_values/ut_data_value.tps
@@expectations/data_values/ut_data_value_anydata.tps
@@expectations/data_values/ut_data_value_blob.tps
@@expectations/data_values/ut_data_value_boolean.tps
@@expectations/data_values/ut_data_value_clob.tps
@@expectations/data_values/ut_data_value_date.tps
@@expectations/data_values/ut_data_value_dsinterval.tps
@@expectations/data_values/ut_data_value_number.tps
@@expectations/data_values/ut_data_value_refcursor.tps
@@expectations/data_values/ut_data_value_timestamp.tps
@@expectations/data_values/ut_data_value_timestamp_tz.tps
@@expectations/data_values/ut_data_value_timestamp_ltz.tps
@@expectations/data_values/ut_data_value_varchar2.tps
@@expectations/data_values/ut_data_value_yminterval.tps
@@expectations/matchers/ut_matcher.tps
@@expectations/matchers/be_false.tps
@@expectations/matchers/be_greater_or_equal.tps
@@expectations/matchers/be_greater_than.tps
@@expectations/matchers/be_less_or_equal.tps
@@expectations/matchers/be_less_than.tps
@@expectations/matchers/be_like.tps
@@expectations/matchers/be_not_null.tps
@@expectations/matchers/be_null.tps
@@expectations/matchers/be_true.tps
@@expectations/matchers/equal.tps
@@expectations/matchers/be_between.tps
@@expectations/matchers/match.tps
@@expectations/ut_expectation.tps
@@expectations/ut_expectation_anydata.tps
@@expectations/ut_expectation_blob.tps
@@expectations/ut_expectation_boolean.tps
@@expectations/ut_expectation_clob.tps
@@expectations/ut_expectation_date.tps
@@expectations/ut_expectation_dsinterval.tps
@@expectations/ut_expectation_number.tps
@@expectations/ut_expectation_refcursor.tps
@@expectations/ut_expectation_timestamp.tps
@@expectations/ut_expectation_timestamp_ltz.tps
@@expectations/ut_expectation_timestamp_tz.tps
@@expectations/ut_expectation_varchar2.tps
@@expectations/ut_expectation_yminterval.tps
@@expectations/data_values/ut_data_value_anydata.tpb
@@expectations/data_values/ut_data_value_blob.tpb
@@expectations/data_values/ut_data_value_boolean.tpb
@@expectations/data_values/ut_data_value_clob.tpb
@@expectations/data_values/ut_data_value_date.tpb
@@expectations/data_values/ut_data_value_dsinterval.tpb
@@expectations/data_values/ut_data_value_number.tpb
@@expectations/data_values/ut_data_value_refcursor.tpb
@@expectations/data_values/ut_data_value_timestamp.tpb
@@expectations/data_values/ut_data_value_timestamp_tz.tpb
@@expectations/data_values/ut_data_value_timestamp_ltz.tpb
@@expectations/data_values/ut_data_value_varchar2.tpb
@@expectations/data_values/ut_data_value_yminterval.tpb
@@expectations/matchers/ut_matcher.tpb
@@expectations/matchers/be_false.tpb
@@expectations/matchers/be_greater_or_equal.tpb
@@expectations/matchers/be_greater_than.tpb
@@expectations/matchers/be_less_or_equal.tpb
@@expectations/matchers/be_less_than.tpb
@@expectations/matchers/be_like.tpb
@@expectations/matchers/be_not_null.tpb
@@expectations/matchers/be_null.tpb
@@expectations/matchers/be_true.tpb
@@expectations/matchers/equal.tpb
@@expectations/matchers/be_between.tpb
@@expectations/matchers/match.tpb
@@expectations/ut_expectation.tpb
@@expectations/ut_expectation_anydata.tpb
@@expectations/ut_expectation_blob.tpb
@@expectations/ut_expectation_boolean.tpb
@@expectations/ut_expectation_clob.tpb
@@expectations/ut_expectation_date.tpb
@@expectations/ut_expectation_dsinterval.tpb
@@expectations/ut_expectation_number.tpb
@@expectations/ut_expectation_refcursor.tpb
@@expectations/ut_expectation_timestamp.tpb
@@expectations/ut_expectation_timestamp_ltz.tpb
@@expectations/ut_expectation_timestamp_tz.tpb
@@expectations/ut_expectation_varchar2.tpb
@@expectations/ut_expectation_yminterval.tpb

--expectations interface
@@expectations/ut.pks
@@expectations/ut.pkb

@@reporters/ut_teamcity_reporter.tps
@@reporters/ut_teamcity_reporter_helper.pks
@@reporters/ut_teamcity_reporter_helper.pkb
@@reporters/ut_teamcity_reporter.tpb
@@reporters/ut_documentation_reporter.tps
@@reporters/ut_documentation_reporter.tpb


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

spool off

exit success
