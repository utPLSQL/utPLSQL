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

set feedback on

spool uninstall.log

prompt &&line_separator
prompt Uninstalling UTPLSQL v3 framework
prompt &&line_separator

alter session set current_schema = &&ut3_owner;
set echo on
drop synonym be_between;

drop synonym match;

drop synonym be_false;

drop synonym be_empty;

drop synonym be_greater_or_equal;

drop synonym be_greater_than;

drop synonym be_less_or_equal;

drop synonym be_less_than;

drop synonym be_like;

drop synonym be_not_null;

drop synonym be_null;

drop synonym be_true;

drop synonym equal;

drop type ut_coveralls_reporter force;

drop type ut_coverage_sonar_reporter force;

drop package ut_coverage_report_html_helper;

drop type ut_coverage_html_reporter force;

drop type ut_sonar_test_reporter force;

drop package ut_coverage;

drop package ut_coverage_helper;

drop view ut_coverage_sources_tmp;

drop table ut_coverage_sources_tmp$;

drop package ut_teamcity_reporter_helper;

drop package ut_runner;

drop package ut_suite_manager;

drop package ut_suite_builder;

drop package ut;

drop table ut_dbms_output_cache;

drop type ut_expectation force;

drop package ut_expectation_processor;

drop type ut_match force;

drop type ut_be_between force;

drop type ut_equal force;

drop type ut_be_true force;

drop type ut_be_null force;

drop type ut_be_not_null force;

drop type ut_be_like force;

drop type ut_be_greater_or_equal force;

drop type ut_be_empty force;

drop type ut_be_greater_than force;

drop type ut_be_less_or_equal force;

drop type ut_be_less_than force;

drop type ut_be_false force;

drop type ut_comparison_matcher force;

drop type ut_matcher force;

drop type ut_data_value_yminterval force;

drop type ut_data_value_varchar2 force;

drop type ut_data_value_timestamp_tz force;

drop type ut_data_value_timestamp_ltz force;

drop type ut_data_value_timestamp force;

drop type ut_data_value_number force;

drop type ut_data_value_refcursor force;

drop type ut_data_value_dsinterval force;

drop type ut_data_value_date force;

drop type ut_data_value_clob force;

drop type ut_data_value_boolean force;

drop type ut_data_value_blob force;

drop type ut_data_value_object force;

drop type ut_data_value_collection force;

drop type ut_data_value_anydata force;

drop type ut_data_value force;

drop table ut_data_set_tmp;

drop table ut_data_set_diff_tmp;

drop package ut_annotation_manager;

drop package ut_annotation_parser;

drop package ut_annotation_cache_manager;

drop table ut_annotation_cache cascade constraints;

drop table ut_annotation_cache_info cascade constraints;

drop sequence ut_annotation_cache_seq;

drop type ut_annotation_objs_cache_info force;

drop type ut_annotation_obj_cache_info force;

drop type ut_annotated_objects force;

drop type ut_annotated_object force;

drop type ut_annotations force;

drop type ut_annotation force;

drop package ut_file_mapper;

drop package ut_metadata;

drop package ut_ansiconsole_helper;

drop package ut_utils;

drop type ut_documentation_reporter force;

drop type ut_teamcity_reporter force;

drop type ut_xunit_reporter force;

drop type ut_event_listener force;

drop type ut_coverage_reporter_base force;

drop type ut_reporters force;

drop type ut_reporter_base force;

drop type ut_run force;

drop type ut_coverage_options force;

drop type ut_file_mappings force;

drop type ut_file_mapping force;

drop type ut_suite force;

drop type ut_logical_suite force;

drop type ut_test force;

drop type ut_console_reporter_base force;

drop type ut_executable force;

drop type ut_suite_items force;

drop type ut_suite_item force;

drop type ut_event_listener_base force;

drop type ut_suite_item_base force;

drop package ut_output_buffer;

drop view ut_output_buffer_tmp;

drop table ut_output_buffer_tmp$;

drop sequence ut_message_id_seq;

drop type ut_results_counter force;

drop type ut_expectation_results force;

drop type ut_expectation_result force;

drop type ut_key_value_pairs force;

drop type ut_key_value_pair force;

drop type ut_object_names force;

drop type ut_object_name force;

drop type ut_varchar2_list force;

drop type ut_varchar2_rows force;

set echo off
set feedback off
declare
  i integer := 0;
begin
  dbms_output.put_line('Dropping synonyms pointing to non-existing objects in schema '||upper('&&ut3_owner'));
  for syn in (
    select
      case when owner = 'PUBLIC'
        then 'public synonym '
        else 'synonym ' || owner || '.' end || synonym_name as syn_name,
      table_owner||'.'||table_name as for_object
    from all_synonyms s
    where table_owner = upper('&&ut3_owner') and table_owner != owner
      and not exists (select 1 from all_objects o where o.owner = s.table_owner and o.object_name = s.table_name)
  )
  loop
    i := i + 1;
    begin
      execute immediate 'drop '||syn.syn_name;
      dbms_output.put_line('Dropped '||syn.syn_name||' for object '||syn.for_object);
    exception
      when others then
        dbms_output.put_line('FAILED to drop '||syn.syn_name||' for object '||syn.for_object);
    end;
  end loop;
  dbms_output.put_line('&&line_separator');
  dbms_output.put_line(i||' synonyms dropped');
end;
/
begin
  dbms_output.put_line('&&line_separator');
  dbms_output.put_line('Uninstall complete');
  dbms_output.put_line('&&line_separator');
end;
/

spool off
