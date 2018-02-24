/*
  utPLSQL - Version 3
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
--set define off

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
@@install_component.sql 'core/ut_utils.pks'
@@install_component.sql 'core/ut_metadata.pks'
@@install_component.sql 'core/ut_utils.pkb'
@@install_component.sql 'core/ut_metadata.pkb'
@@install_component.sql 'reporters/ut_ansiconsole_helper.pks'
@@install_component.sql 'reporters/ut_ansiconsole_helper.pkb'

--core types
@@install_component.sql 'core/types/ut_expectation_result.tps'
@@install_component.sql 'core/types/ut_expectation_results.tps'
@@install_component.sql 'core/types/ut_results_counter.tps'
@@install_component.sql 'core/types/ut_suite_item_base.tps'
@@install_component.sql 'core/types/ut_event_listener_base.tps'
@@install_component.sql 'core/types/ut_suite_item.tps'
@@install_component.sql 'core/types/ut_suite_items.tps'
@@install_component.sql 'core/types/ut_executable.tps'
@@install_component.sql 'core/types/ut_executable_test.tps'
@@install_component.sql 'core/types/ut_test.tps'
@@install_component.sql 'core/types/ut_logical_suite.tps'
@@install_component.sql 'core/types/ut_suite.tps'
@@install_component.sql 'core/types/ut_file_mapping.tps'
@@install_component.sql 'core/types/ut_file_mappings.tps'
@@install_component.sql 'core/types/ut_coverage_options.tps'
@@install_component.sql 'core/types/ut_run.tps'
@@install_component.sql 'core/types/ut_reporter_base.tps'
@@install_component.sql 'core/types/ut_reporters.tps'
@@install_component.sql 'core/types/ut_event_listener.tps'

--output buffer table
@@install_component.sql 'core/ut_output_buffer_tmp.sql'
@@install_component.sql 'core/ut_message_id_seq.sql'
--output buffer api
@@install_component.sql 'core/ut_output_buffer.pks'
@@install_component.sql 'core/ut_output_buffer.pkb'

--annoations
@@install_component.sql 'core/annotations/ut_annotation.tps'
@@install_component.sql 'core/annotations/ut_annotations.tps'
@@install_component.sql 'core/annotations/ut_annotated_object.tps'
@@install_component.sql 'core/annotations/ut_annotated_objects.tps'
@@install_component.sql 'core/annotations/ut_annotation_obj_cache_info.tps'
@@install_component.sql 'core/annotations/ut_annotation_objs_cache_info.tps'
@@install_component.sql 'core/annotations/ut_annotation_cache_seq.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache_info.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache.sql'
@@install_component.sql 'core/annotations/ut_annotation_cache_manager.pks'
@@install_component.sql 'core/annotations/ut_annotation_cache_manager.pkb'
@@install_component.sql 'core/annotations/ut_annotation_parser.pks'
@@install_component.sql 'core/annotations/ut_annotation_parser.pkb'
@@install_component.sql 'core/annotations/ut_annotation_manager.pks'
@@install_component.sql 'core/annotations/ut_annotation_manager.pkb'

--suite builder
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

@@install_component.sql 'core/ut_file_mapper.pks'
@@install_component.sql 'core/ut_file_mapper.pkb'


--gathering coverage
@@install_component.sql 'core/coverage/ut_coverage_sources_tmp.sql'
@@install_component.sql 'core/coverage/ut_coverage_helper.pks'
@@install_component.sql 'core/coverage/ut_coverage_helper.pkb'
@@install_component.sql 'core/coverage/ut_coverage.pks'
@@install_component.sql 'core/coverage/ut_coverage.pkb'
@@install_component.sql 'core/coverage/ut_coverage_reporter_base.tps'
@@install_component.sql 'core/coverage/ut_coverage_reporter_base.tpb'

--core type bodies
@@install_component.sql 'core/types/ut_results_counter.tpb'
@@install_component.sql 'core/types/ut_suite_item.tpb'
@@install_component.sql 'core/types/ut_test.tpb'
@@install_component.sql 'core/types/ut_logical_suite.tpb'
@@install_component.sql 'core/types/ut_suite.tpb'
@@install_component.sql 'core/types/ut_run.tpb'
@@install_component.sql 'core/types/ut_event_listener.tpb'
@@install_component.sql 'core/types/ut_expectation_result.tpb'
@@install_component.sql 'core/types/ut_reporter_base.tpb'
@@install_component.sql 'core/types/ut_file_mapping.tpb'
@@install_component.sql 'core/types/ut_executable.tpb'
@@install_component.sql 'core/types/ut_executable_test.tpb'
@@install_component.sql 'core/types/ut_console_reporter_base.tps'
@@install_component.sql 'core/types/ut_console_reporter_base.tpb'

--expectations and matchers
@@install_component.sql 'expectations/data_values/ut_data_set_tmp.sql'
@@install_component.sql 'expectations/data_values/ut_data_set_diff_tmp.sql'
@@install_component.sql 'expectations/data_values/ut_data_value.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_anydata.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_collection.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_object.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_blob.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_boolean.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_clob.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_date.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_dsinterval.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_number.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_refcursor.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_tz.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_ltz.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_varchar2.tps'
@@install_component.sql 'expectations/data_values/ut_data_value_yminterval.tps'
@@install_component.sql 'expectations/matchers/ut_matcher.tps'
@@install_component.sql 'expectations/matchers/ut_comparison_matcher.tps'
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
@@install_component.sql 'expectations/matchers/ut_have_count.tps'
@@install_component.sql 'expectations/matchers/ut_be_between.tps'
@@install_component.sql 'expectations/matchers/ut_be_empty.tps'
@@install_component.sql 'expectations/matchers/ut_match.tps'
@@install_component.sql 'expectations/ut_expectation.tps'
@@install_component.sql 'expectations/ut_expectation_compound.tps'
@@install_component.sql 'expectations/data_values/ut_data_value.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_anydata.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_object.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_collection.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_blob.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_boolean.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_clob.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_date.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_dsinterval.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_number.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_refcursor.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_tz.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_timestamp_ltz.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_varchar2.tpb'
@@install_component.sql 'expectations/data_values/ut_data_value_yminterval.tpb'
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
@@install_component.sql 'expectations/matchers/ut_have_count.tpb'
@@install_component.sql 'expectations/matchers/ut_be_between.tpb'
@@install_component.sql 'expectations/matchers/ut_be_empty.tpb'
@@install_component.sql 'expectations/matchers/ut_match.tpb'
@@install_component.sql 'expectations/ut_expectation.tpb'
@@install_component.sql 'expectations/ut_expectation_compound.tpb'

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
@@install_component.sql 'reporters/ut_teamcity_reporter.tps'
@@install_component.sql 'reporters/ut_teamcity_reporter_helper.pks'
@@install_component.sql 'reporters/ut_teamcity_reporter_helper.pkb'
@@install_component.sql 'reporters/ut_teamcity_reporter.tpb'
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
@@install_component.sql 'api/equal.syn'
@@install_component.sql 'api/have_count.syn'
@@install_component.sql 'api/match.syn'

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
