/*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
prompt Installing utplsql framework

set serveroutput on size unlimited
set timing off
set verify off
set define &

spool install.log

define ut3_owner = &1
alter session set current_schema = &&ut3_owner;
alter session set plsql_warnings = 'ENABLE:ALL', 'DISABLE:(6000,6001,6003,6010, 7206)';
set define off


whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

--common utilities
@@core/types/ut_varchar2_list.tps
@@core/types/ut_object_name.tps
@@core/types/ut_object_name.tpb
@@core/types/ut_object_names.tps
@@core/types/ut_key_value_pair.tps
@@core/types/ut_key_value_pairs.tps
@@core/ut_utils.pks
@@core/ut_metadata.pks
@@core/ut_utils.pkb
@@core/ut_metadata.pkb
@@reporters/ut_ansiconsole_helper.pks
@@reporters/ut_ansiconsole_helper.pkb

--core types
@@core/types/ut_assert_result.tps
@@core/types/ut_assert_results.tps
@@core/types/ut_results_counter.tps
@@core/types/ut_suite_item_base.tps
@@core/types/ut_event_listener_base.tps
@@core/types/ut_suite_item.tps
@@core/types/ut_suite_items.tps
@@core/types/ut_executable.tps
@@core/types/ut_test.tps
@@core/types/ut_logical_suite.tps
@@core/types/ut_suite.tps
@@core/types/ut_run.tps
@@core/types/ut_reporter_base.tps
@@core/types/ut_reporters.tps
@@core/types/ut_coverage_reporter_base.tps
@@core/types/ut_event_listener.tps

--output buffer table
@@core/ut_output_buffer_tmp.sql
@@core/ut_message_id_seq.sql
--output buffer api
@@core/ut_output_buffer.pks
@@core/ut_output_buffer.pkb

--annoations
@@core/ut_annotations.pks
@@core/ut_annotations.pkb

--suite manager
@@core/ut_suite_manager.pks
@@core/ut_suite_manager.pkb

--assertios execution state interface
@@core/ut_assert_processor.pks
@@core/ut_assert_processor.pkb

--gathering coverage
@@core/coverage/proftab_temp_tables.sql
@@core/coverage/ut_coverage_sources_tmp.sql
@@core/coverage/ut_coverage_helper.pks
@@core/coverage/ut_coverage_helper.pkb
@@core/coverage/ut_coverage_file_mapping.tps
@@core/coverage/ut_coverage_file_mappings.tps
@core/coverage/ut_coverage.pks
@@core/coverage/ut_coverage.pkb

--core type bodies
@@core/types/ut_results_counter.tpb
@@core/types/ut_suite_item.tpb
@@core/types/ut_test.tpb
@@core/types/ut_logical_suite.tpb
@@core/types/ut_suite.tpb
@@core/types/ut_run.tpb
@@core/types/ut_event_listener.tpb
@@core/types/ut_assert_result.tpb
@@core/types/ut_reporter_base.tpb
@@core/types/ut_coverage_reporter_base.tpb
@@core/types/ut_executable.tpb
@@core/types/ut_console_reporter_base.tps
@@core/types/ut_console_reporter_base.tpb

--expectations and matchers
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
@@expectations/matchers/ut_be_false.tps
@@expectations/matchers/ut_be_greater_or_equal.tps
@@expectations/matchers/ut_be_greater_than.tps
@@expectations/matchers/ut_be_less_or_equal.tps
@@expectations/matchers/ut_be_less_than.tps
@@expectations/matchers/ut_be_like.tps
@@expectations/matchers/ut_be_not_null.tps
@@expectations/matchers/ut_be_null.tps
@@expectations/matchers/ut_be_true.tps
@@expectations/matchers/ut_equal.tps
@@expectations/matchers/ut_be_between.tps
@@expectations/matchers/ut_be_empty.tps
@@expectations/matchers/ut_match.tps
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
@@expectations/matchers/ut_be_false.tpb
@@expectations/matchers/ut_be_greater_or_equal.tpb
@@expectations/matchers/ut_be_greater_than.tpb
@@expectations/matchers/ut_be_less_or_equal.tpb
@@expectations/matchers/ut_be_less_than.tpb
@@expectations/matchers/ut_be_like.tpb
@@expectations/matchers/ut_be_not_null.tpb
@@expectations/matchers/ut_be_null.tpb
@@expectations/matchers/ut_be_true.tpb
@@expectations/matchers/ut_equal.tpb
@@expectations/matchers/ut_be_between.tpb
@@expectations/matchers/ut_be_empty.tpb
@@expectations/matchers/ut_match.tpb
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

--core reporter
@@reporters/ut_documentation_reporter.tps
@@reporters/ut_documentation_reporter.tpb

--plugin interface API for running utPLSQL
@@api/ut_runner.pks
@@api/ut_runner.pkb

--developer interface for expectations and running utPLSQL
@@api/ut.pks
@@api/ut.pkb

--additional reporters
@@reporters/ut_teamcity_reporter.tps
@@reporters/ut_teamcity_reporter_helper.pks
@@reporters/ut_teamcity_reporter_helper.pkb
@@reporters/ut_teamcity_reporter.tpb
@@reporters/ut_xunit_reporter.tps
@@reporters/ut_xunit_reporter.tpb


@@reporters/ut_coverage_html_reporter.tps
@@reporters/ut_coverage_report_html_helper.pks
@@reporters/ut_coverage_report_html_helper.pkb
@@reporters/ut_coverage_html_reporter.tpb

@@api/be_between.syn
@@api/be_empty.syn
@@api/be_false.syn
@@api/be_greater_or_equal.syn
@@api/be_greater_than.syn
@@api/be_less_or_equal.syn
@@api/be_less_than.syn
@@api/be_like.syn
@@api/be_not_null.syn
@@api/be_null.syn
@@api/be_true.syn
@@api/equal.syn
@@api/match.syn


set linesize 200
set define &
column text format a100
column error_count noprint new_value error_count
prompt Validating installation
select name, type, sequence, line, position, text, count(1) over() error_count
  from all_errors
 where owner = upper('&&ut3_owner')
   and name not like 'BIN$%'  --not recycled
   and (name = 'UT' or name like 'UT\_%' escape '\')
   -- errors only. ignore warnings
   and attribute = 'ERROR'
/

begin
  if to_number('&&error_count') > 0 then
    raise_application_error(-20000, 'Not all sources were successfully installed.');
  end if;
end;
/

spool off

exit success
