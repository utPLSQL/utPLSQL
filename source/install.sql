/*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

@@define_ut3_owner_param.sql

spool install.log

prompt &&line_separator
prompt Installing utPLSQL v3 framework into &&ut3_owner schema
prompt &&line_separator

whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

prompt Switching current schema to &&ut3_owner
prompt &&line_separator
alter session set current_schema = &&ut3_owner;

@@check_object_grants.sql
@@check_sys_grants.sql "'CREATE TYPE','CREATE VIEW','CREATE SYNONYM','CREATE SEQUENCE','CREATE PROCEDURE','CREATE TABLE', 'CREATE CONTEXT'"
--set define off

create or replace context &&ut3_owner._info using &&ut3_owner..ut_session_context;

--dbms_output buffer cache table
@@install_component.sql 'core/ut_dbms_output_cache.sql'

--common utilities
@@install_component.sql 'core/types/ut_varchar2_list.tps'
@@install_component.sql 'core/types/ut_varchar2_rows.tps'
@@install_component.sql 'core/types/ut_integer_list.tps'
@@install_component.sql 'core/types/ut_object_name.tps'
@@install_component.sql 'core/types/ut_object_name.tpb'
@@install_component.sql 'core/types/ut_object_names.tps'
@@install_component.sql 'core/types/ut_key_value_pair.tps'
@@install_component.sql 'core/types/ut_key_value_pairs.tps'
@@install_component.sql 'core/types/ut_reporter_info.tps'
@@install_component.sql 'core/types/ut_reporters_info.tps'
@@install_component.sql 'core/ut_utils.pks'
@@install_component.sql 'core/ut_metadata.pks'
@@install_component.sql 'core/ut_savepoint_seq.sql'
@@install_component.sql 'core/ut_utils.pkb'
@@install_component.sql 'core/ut_metadata.pkb'
@@install_component.sql 'reporters/ut_ansiconsole_helper.pks'
@@install_component.sql 'reporters/ut_ansiconsole_helper.pkb'

@@install_component.sql 'api/ut_suite_item_info.tps'
@@install_component.sql 'api/ut_suite_item_info.tpb'
@@install_component.sql 'api/ut_suite_items_info.tps'

--event manager objects
@@install_component.sql 'core/events/ut_event_item.tps'
@@install_component.sql 'core/events/ut_event_listener.tps'
@@install_component.sql 'core/events/ut_event_manager.pks'
@@install_component.sql 'core/events/ut_event_manager.pkb'

--core types
@@install_component.sql 'core/types/ut_run_info.tps'
@@install_component.sql 'core/types/ut_run_info.tpb'
@@install_component.sql 'core/types/ut_expectation_result.tps'
@@install_component.sql 'core/types/ut_expectation_results.tps'
@@install_component.sql 'core/types/ut_results_counter.tps'
@@install_component.sql 'core/types/ut_suite_item.tps'
@@install_component.sql 'core/types/ut_suite_items.tps'
@@install_component.sql 'core/types/ut_executable.tps'
@@install_component.sql 'core/types/ut_executables.tps'
@@install_component.sql 'core/types/ut_executable_test.tps'
@@install_component.sql 'core/types/ut_test.tps'
@@install_component.sql 'core/types/ut_logical_suite.tps'
@@install_component.sql 'core/types/ut_suite.tps'
@@install_component.sql 'core/types/ut_suite_context.tps'
@@install_component.sql 'core/types/ut_file_mapping.tps'
@@install_component.sql 'core/types/ut_file_mappings.tps'
@@install_component.sql 'core/types/ut_coverage_options.tps'
@@install_component.sql 'core/types/ut_run.tps'
@@install_component.sql 'core/types/ut_reporter_base.tps'
@@install_component.sql 'core/types/ut_reporters.tps'


@@install_component.sql 'expectations/json_objects_specs.sql'
@@install_component.sql 'expectations/matchers/ut_matcher_options_items.tps'
@@install_component.sql 'expectations/matchers/ut_matcher_options.tps'
@@install_component.sql 'expectations/data_values/ut_data_value.tps'
@@install_component.sql 'expectations/data_values/ut_key_anyval_pair.tps'
@@install_component.sql 'expectations/data_values/ut_key_anyval_pairs.tps'
@@install_component.sql 'expectations/data_values/ut_key_anyvalues.tps'

--session_context
@@install_component.sql  'core/session_context/ut_session_context.pks'
@@install_component.sql  'core/session_context/ut_session_context.pkb'
@@install_component.sql  'core/session_context/ut_session_info.tps'
@@install_component.sql  'core/session_context/ut_session_info.tpb'

--output buffer table
@@install_component.sql 'core/output_buffers/ut_output_buffer_info_tmp.sql'
@@install_component.sql 'core/output_buffers/ut_output_buffer_tmp.sql'
@@install_component.sql 'core/output_buffers/ut_output_clob_buffer_tmp.sql'
--output buffer base api
@@install_component.sql 'core/output_buffers/ut_output_data_row.tps'
@@install_component.sql 'core/output_buffers/ut_output_data_rows.tps'
@@install_component.sql 'core/output_buffers/ut_output_buffer_base.tps'
@@install_component.sql 'core/output_buffers/ut_output_buffer_base.tpb'
--output buffer table api
@@install_component.sql 'core/output_buffers/ut_output_table_buffer.tps'
@@install_component.sql 'core/output_buffers/ut_output_table_buffer.tpb'
@@install_component.sql 'core/output_buffers/ut_output_clob_table_buffer.tps'
@@install_component.sql 'core/output_buffers/ut_output_clob_table_buffer.tpb'

@@install_component.sql 'core/types/ut_output_reporter_base.tps'

--annotations
@@install_component.sql 'core/annotations/ut_trigger_check.pks'
@@install_component.sql 'core/annotations/ut_trigger_check.pkb'
@@install_component.sql 'core/annotations/ut_annotation.tps'
@@install_component.sql 'core/annotations/ut_annotations.tps'
@@install_component.sql 'core/annotations/ut_annotated_object.tps'
@@install_component.sql 'core/annotations/ut_annotated_objects.tps'
@@install_component.sql 'core/annotations/ut_annotation_obj_cache_info.tps'
@@install_component.sql 'core/annotations/ut_annotation_objs_cache_info.tps'
@@install_component.sql 'core/annotations/ut_annotation_cache_seq.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache_schema.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache_info.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache_manager.pks'
@@install_component.sql 'core/annotations/ut_annotation_cache_manager.pkb'
@@install_component.sql 'core/annotations/ut_annotation_parser.pks'
@@install_component.sql 'core/annotations/ut_annotation_parser.pkb'
@@install_component.sql 'core/annotations/ut_annotation_manager.pks'
@@install_component.sql 'core/annotations/ut_annotation_manager.pkb'

--suite builder
@@install_component.sql 'core/types/ut_suite_cache_row.tps'
@@install_component.sql 'core/types/ut_suite_cache_rows.tps'
@@install_component.sql 'core/ut_suite_cache_schema.sql'
@@install_component.sql 'core/ut_suite_cache_package.sql'
@@install_component.sql 'core/ut_suite_cache_seq.sql'
@@install_component.sql 'core/ut_suite_cache.sql'

@@install_component.sql 'core/ut_suite_cache_manager.pks'
@@install_component.sql 'core/ut_suite_cache_manager.pkb'
@@install_component.sql 'core/ut_suite_builder.pks'
@@install_component.sql 'core/ut_suite_builder.pkb'
--suite manager
@@install_component.sql 'core/ut_suite_manager.pks'
@@install_component.sql 'core/ut_suite_manager.pkb'

--expectations execution state interface
@@install_component.sql 'core/ut_expectation_processor.pks'
@@install_component.sql 'core/ut_expectation_processor.pkb'

prompt Installing PLSQL profiler objects into &&ut3_owner schema
@@core/coverage/proftab.sql

prompt Installing PLSQL profiler objects into &&ut3_owner schema
@@core/coverage/proftab.sql

prompt Installing DBMSPLSQL Tables objects into &&ut3_owner schema
@@core/coverage/dbms_plssqlcode.sql

@@install_component.sql 'core/ut_file_mapper.pks'
@@install_component.sql 'core/ut_file_mapper.pkb'


--gathering coverage
@@install_component.sql 'core/coverage/ut_coverage_sources_tmp.sql'
@@install_component.sql 'core/coverage/ut_coverage_helper.pks'
@@install_component.sql 'core/coverage/ut_coverage_helper_block.pks'
@@install_component.sql 'core/coverage/ut_coverage_helper_profiler.pks'
@@install_component.sql 'core/coverage/ut_coverage.pks'
@@install_component.sql 'core/coverage/ut_coverage_block.pks'
@@install_component.sql 'core/coverage/ut_coverage_profiler.pks'
@@install_component.sql 'core/coverage/ut_coverage_reporter_base.tps'
@@install_component.sql 'core/coverage/ut_coverage_helper.pkb'
@@install_component.sql 'core/coverage/ut_coverage_helper_block.pkb'
@@install_component.sql 'core/coverage/ut_coverage_helper_profiler.pkb'
@@install_component.sql 'core/coverage/ut_coverage.pkb'
@@install_component.sql 'core/coverage/ut_coverage_block.pkb'
@@install_component.sql 'core/coverage/ut_coverage_profiler.pkb'
@@install_component.sql 'core/coverage/ut_coverage_reporter_base.tpb'

--core type bodies
@@install_component.sql 'core/types/ut_results_counter.tpb'
@@install_component.sql 'core/types/ut_suite_item.tpb'
@@install_component.sql 'core/types/ut_test.tpb'
@@install_component.sql 'core/types/ut_logical_suite.tpb'
@@install_component.sql 'core/types/ut_suite.tpb'
@@install_component.sql 'core/types/ut_suite_context.tpb'
@@install_component.sql 'core/types/ut_run.tpb'
@@install_component.sql 'core/types/ut_expectation_result.tpb'
@@install_component.sql 'core/types/ut_reporter_base.tpb'
@@install_component.sql 'core/types/ut_output_reporter_base.tpb'
@@install_component.sql 'core/types/ut_file_mapping.tpb'
@@install_component.sql 'core/types/ut_executable.tpb'
@@install_component.sql 'core/types/ut_executable_test.tpb'
@@install_component.sql 'core/types/ut_console_reporter_base.tps'
@@install_component.sql 'core/types/ut_console_reporter_base.tpb'

--expectations and matchers
@@install_component.sql 'expectations/data_values/ut_compound_data_tmp.sql'
@@install_component.sql 'expectations/data_values/ut_compound_data_diff_tmp.sql'
@@install_component.sql 'expectations/data_values/ut_json_data_diff_tmp.sql'
@@install_component.sql 'expectations/data_values/ut_compound_data_value.tps'
@@install_component.sql 'expectations/data_values/ut_json_leaf.tps'
@@install_component.sql 'expectations/data_values/ut_json_leaf_tab.tps'
@@install_component.sql 'expectations/data_values/ut_json_tree_details.tps'
@@install_component.sql 'expectations/data_values/ut_cursor_column.tps'
@@install_component.sql 'expectations/data_values/ut_cursor_column_tab.tps'
@@install_component.sql 'expectations/data_values/ut_cursor_details.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_blob.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_boolean.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_clob.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_date.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_dsinterval.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_number.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_refcursor.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_anydata.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_tz.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_ltz.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_varchar2.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_yminterval.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_xmltype.tps'
@@install_component.sql 'expectations/data_values/ut_compound_data_helper.pks'
@@install_component.sql 'expectations/data_values/ut_data_value_json.tps'
@@install_component.sql 'expectations/matchers/ut_matcher_base.tps'
@@install_component.sql 'expectations/ut_expectation_base.tps'
@@install_component.sql 'expectations/matchers/ut_matcher.tps'
@@install_component.sql 'expectations/matchers/ut_comparison_matcher.tps'
@@install_component.sql 'expectations/matchers/ut_be_within_pct.tps'
@@install_component.sql 'expectations/matchers/ut_be_within.tps'
@@install_component.sql 'expectations/matchers/ut_be_within_helper.pks'
@@install_component.sql 'expectations/ut_expectation.tps'
@@install_component.sql 'expectations/matchers/ut_be_false.tps'
@@install_component.sql 'expectations/matchers/ut_be_greater_or_equal.tps'
@@install_component.sql 'expectations/matchers/ut_be_greater_than.tps'
@@install_component.sql 'expectations/matchers/ut_be_less_or_equal.tps'
@@install_component.sql 'expectations/matchers/ut_be_less_than.tps'
@@install_component.sql 'expectations/matchers/ut_be_like.tps'
@@install_component.sql 'expectations/matchers/ut_be_not_null.tps'
@@install_component.sql 'expectations/matchers/ut_be_null.tps'
@@install_component.sql 'expectations/matchers/ut_be_true.tps'
@@install_component.sql 'expectations/matchers/ut_equal.tps'
@@install_component.sql 'expectations/matchers/ut_contain.tps'
@@install_component.sql 'expectations/matchers/ut_have_count.tps'
@@install_component.sql 'expectations/matchers/ut_be_between.tps'
@@install_component.sql 'expectations/matchers/ut_be_empty.tps'
@@install_component.sql 'expectations/matchers/ut_match.tps'
@@install_component.sql 'expectations/data_values/ut_json_leaf.tpb'
@@install_component.sql 'expectations/data_values/ut_json_tree_details.tpb'
@@install_component.sql 'expectations/data_values/ut_cursor_column.tpb'
@@install_component.sql 'expectations/data_values/ut_cursor_details.tpb'
@@install_component.sql 'expectations/ut_expectation_compound.tps'
@@install_component.sql 'expectations/ut_expectation_json.tps'

@@install_component.sql 'expectations/matchers/ut_matcher_options_items.tpb'
@@install_component.sql 'expectations/matchers/ut_matcher_options.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value.tpb'
@@install_component.sql 'expectations/data_values/ut_compound_data_value.tpb'
@@install_component.sql 'expectations/data_values/ut_compound_data_helper.pkb'
@@install_component.sql 'expectations/data_values/ut_data_value_blob.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_boolean.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_clob.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_date.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_dsinterval.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_number.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_refcursor.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_anydata.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_tz.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_ltz.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_varchar2.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_yminterval.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_xmltype.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_json.tpb'
@@install_component.sql 'expectations/matchers/ut_matcher.tpb'
@@install_component.sql 'expectations/matchers/ut_comparison_matcher.tpb'
@@install_component.sql 'expectations/matchers/ut_be_false.tpb'
@@install_component.sql 'expectations/matchers/ut_be_greater_or_equal.tpb'
@@install_component.sql 'expectations/matchers/ut_be_greater_than.tpb'
@@install_component.sql 'expectations/matchers/ut_be_less_or_equal.tpb'
@@install_component.sql 'expectations/matchers/ut_be_less_than.tpb'
@@install_component.sql 'expectations/matchers/ut_be_like.tpb'
@@install_component.sql 'expectations/matchers/ut_be_not_null.tpb'
@@install_component.sql 'expectations/matchers/ut_be_null.tpb'
@@install_component.sql 'expectations/matchers/ut_be_true.tpb'
@@install_component.sql 'expectations/matchers/ut_equal.tpb'
@@install_component.sql 'expectations/matchers/ut_be_within_pct.tpb'
@@install_component.sql 'expectations/matchers/ut_be_within.tpb'
@@install_component.sql 'expectations/matchers/ut_be_within_helper.pkb'
@@install_component.sql 'expectations/matchers/ut_contain.tpb'
@@install_component.sql 'expectations/matchers/ut_have_count.tpb'
@@install_component.sql 'expectations/matchers/ut_be_between.tpb'
@@install_component.sql 'expectations/matchers/ut_be_empty.tpb'
@@install_component.sql 'expectations/matchers/ut_match.tpb'
@@install_component.sql 'expectations/ut_expectation_base.tpb'
@@install_component.sql 'expectations/ut_expectation.tpb'
@@install_component.sql 'expectations/ut_expectation_compound.tpb'
@@install_component.sql 'expectations/ut_expectation_json.tpb'
@@install_component.sql 'expectations/data_values/ut_key_anyvalues.tpb'

--core reporter
@@install_component.sql 'reporters/ut_documentation_reporter.tps'
@@install_component.sql 'reporters/ut_documentation_reporter.tpb'

--plugin interface API for running utPLSQL
@@install_component.sql 'api/ut_runner.pks'
@@install_component.sql 'api/ut_runner.pkb'

--developer interface for expectations and running utPLSQL
@@install_component.sql 'api/ut.pks'
@@install_component.sql 'api/ut.pkb'

--additional reporters
@@install_component.sql 'reporters/ut_debug_reporter.tps'
@@install_component.sql 'reporters/ut_debug_reporter.tpb'
@@install_component.sql 'reporters/ut_teamcity_reporter.tps'
@@install_component.sql 'reporters/ut_teamcity_reporter_helper.pks'
@@install_component.sql 'reporters/ut_teamcity_reporter_helper.pkb'
@@install_component.sql 'reporters/ut_teamcity_reporter.tpb'
@@install_component.sql 'reporters/ut_junit_reporter.tps'
@@install_component.sql 'reporters/ut_junit_reporter.tpb'
@@install_component.sql 'reporters/ut_tfs_junit_reporter.tps'
@@install_component.sql 'reporters/ut_tfs_junit_reporter.tpb'
@@install_component.sql 'reporters/ut_xunit_reporter.tps'
@@install_component.sql 'reporters/ut_xunit_reporter.tpb'
@@install_component.sql 'reporters/ut_sonar_test_reporter.tps'
@@install_component.sql 'reporters/ut_sonar_test_reporter.tpb'

@@install_component.sql 'reporters/ut_coverage_html_reporter.tps'
@@install_component.sql 'reporters/ut_coverage_report_html_helper.pks'
@@install_component.sql 'reporters/ut_coverage_report_html_helper.pkb'
@@install_component.sql 'reporters/ut_coverage_html_reporter.tpb'
@@install_component.sql 'reporters/ut_coverage_sonar_reporter.tps'
@@install_component.sql 'reporters/ut_coverage_sonar_reporter.tpb'
@@install_component.sql 'reporters/ut_coveralls_reporter.tps'
@@install_component.sql 'reporters/ut_coveralls_reporter.tpb'
@@install_component.sql 'reporters/ut_coverage_cobertura_reporter.tps'
@@install_component.sql 'reporters/ut_coverage_cobertura_reporter.tpb'
@@install_component.sql 'reporters/ut_realtime_reporter.tps'
@@install_component.sql 'reporters/ut_realtime_reporter.tpb'

@@install_component.sql 'api/be_between.syn'
@@install_component.sql 'api/be_empty.syn'
@@install_component.sql 'api/be_false.syn'
@@install_component.sql 'api/be_greater_or_equal.syn'
@@install_component.sql 'api/be_greater_than.syn'
@@install_component.sql 'api/be_less_or_equal.syn'
@@install_component.sql 'api/be_less_than.syn'
@@install_component.sql 'api/be_like.syn'
@@install_component.sql 'api/be_not_null.syn'
@@install_component.sql 'api/be_null.syn'
@@install_component.sql 'api/be_true.syn'
@@install_component.sql 'api/be_within_pct.syn'
@@install_component.sql 'api/be_within.syn'
@@install_component.sql 'api/equal.syn'
@@install_component.sql 'api/have_count.syn'
@@install_component.sql 'api/match.syn'
@@install_component.sql 'api/contain.syn'

set linesize 200
set define on
column text format a100
column error_count noprint new_value error_count

prompt Validating installation
prompt &&line_separator
set heading on
select type, name, sequence, line, position, text, count(1) over() error_count
  from all_errors
 where owner = upper('&&ut3_owner')
   and name not like 'BIN$%'  --not recycled
   and (name = 'UT' or name like 'UT\_%' escape '\')
   -- errors only. ignore warnings
   and attribute = 'ERROR'
 order by name, type, sequence
/

begin
  if to_number('&&error_count') > 0 then
    raise_application_error(-20000, 'Not all sources were successfully installed.');
  else
    dbms_output.put_line('Installation completed successfully');
    dbms_output.put_line('&&line_separator');
  end if;
end;
/

spool off
