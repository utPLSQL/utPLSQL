set echo off
declare
  procedure drop_if_exists(a_object_type varchar2, a_object_name varchar2) is
    l_count integer;
  begin
    select count(1)
      into l_count
      from all_objects
     where owner = sys_context('USERENV','CURRENT_SCHEMA')
       and object_type = a_object_type
       and object_name = a_object_name;
    if l_count > 0 then
      execute immediate 'drop '||a_object_type||' '||a_object_name;
      dbms_output.put_line(initcap(a_object_type)||' '||a_object_name||' dropped.');
    else
      dbms_output.put_line(initcap(a_object_type)||' '||a_object_name||' was not dropped, '||lower(a_object_type)||' does not exist.');
    end if;
  end;
begin
  drop_if_exists('TRIGGER', 'UT_TRIGGER_ANNOTATION_PARSING');
  drop_if_exists('SYNONYM','UT3_TRIGGER_ALIVE');
end;
/
set echo on

drop synonym be_between;

drop synonym have_count;

drop synonym match;

drop synonym contain;

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

drop synonym be_within;

drop synonym be_within_pct;

drop type ut_coveralls_reporter force;

drop type ut_coverage_sonar_reporter force;

drop type ut_coverage_cobertura_reporter force;

drop package ut_coverage_report_html_helper;

drop type ut_coverage_html_reporter force;

drop type ut_sonar_test_reporter force;

drop type ut_realtime_reporter force;

drop package ut_coverage;

drop package ut_coverage_helper;

drop table ut_coverage_sources_tmp purge;

drop table ut_coverage_runs purge;

drop package ut_teamcity_reporter_helper;

drop package ut_runner;

drop type ut_suite_items_info force;

drop type ut_suite_item_info force;

drop type ut_path_items force;

drop type ut_path_item force;

drop package ut_suite_manager;

drop package ut_suite_builder;

drop package ut_suite_cache_manager;

drop table ut_suite_cache purge;

drop type ut_suite_cache_rows force;

drop type ut_suite_cache_row force;

drop sequence ut_suite_cache_seq;

drop table ut_suite_cache_package purge;

drop table ut_suite_cache_schema purge;

drop package ut;

drop table ut_dbms_output_cache purge;

drop type ut_expectation_compound force;

drop type ut_expectation_json force;

drop type ut_expectation force;

drop package ut_expectation_processor;

drop type ut_match force;

drop type ut_be_between force;

drop type ut_contain force;

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

drop type ut_be_within_pct force;

drop type ut_be_within force;

drop package ut_be_within_helper;

drop type ut_comparison_matcher force;

drop type ut_matcher force;

drop type ut_expectation_base force;

drop type ut_matcher_base force;

drop type ut_data_value_yminterval force;

drop type ut_data_value_varchar2 force;

drop type ut_data_value_timestamp_tz force;

drop type ut_data_value_timestamp_ltz force;

drop type ut_data_value_timestamp force;

drop type ut_data_value_number force;

drop type ut_data_value_refcursor force;

drop type ut_data_value_json force;

drop type ut_data_value_dsinterval force;

drop type ut_data_value_date force;

drop type ut_data_value_clob force;

drop type ut_data_value_boolean force;

drop type ut_data_value_blob force;

drop type ut_data_value_anydata force;

drop type ut_data_value_xmltype force;

drop type ut_data_value force;

drop type ut_matcher_options force;

drop type ut_matcher_options_items force;

drop type ut_json_tree_details force;

drop type ut_json_leaf_tab force;

drop type ut_json_leaf;

drop type ut_cursor_details force;

drop type ut_cursor_column_tab force;

drop type ut_cursor_column force;

drop table ut_compound_data_tmp purge;

drop table ut_compound_data_diff_tmp purge;

drop table ut_json_data_diff_tmp purge;

drop package ut_annotation_manager;

drop package ut_annotation_parser;

drop package ut_annotation_cache_manager;

drop table ut_annotation_cache cascade constraints purge;

drop table ut_annotation_cache_info cascade constraints purge;

drop table ut_annotation_cache_schema cascade constraints purge;

drop sequence ut_annotation_cache_seq;

drop type ut_annotation_objs_cache_info force;

drop type ut_annotation_obj_cache_info force;

drop type ut_annotated_objects force;

drop type ut_annotated_object force;

drop type ut_annotations force;

drop type ut_annotation force;

drop package ut_trigger_check;

drop package ut_file_mapper;

drop package ut_metadata;

drop package ut_ansiconsole_helper;

begin
  null;
  $if dbms_db_version.version < 21 $then
    begin execute immediate 'drop type json force'; exception when others then null; end;
  $end
  $if dbms_db_version.version = 12 and dbms_db_version.release = 1 or dbms_db_version.version < 12 $then
    begin execute immediate 'drop type json_element_t force'; exception when others then null; end;
    begin execute immediate 'drop type json_object_t force'; exception when others then null; end;
    begin execute immediate 'drop type json_array_t force'; exception when others then null; end;
    begin execute immediate 'drop type json_key_list force'; exception when others then null; end;
  $end
end;
/

drop package ut_utils;

drop sequence ut_savepoint_seq;

drop type ut_documentation_reporter force;

drop type ut_debug_reporter force;

drop type ut_teamcity_reporter force;

drop type ut_xunit_reporter force;

drop type ut_junit_reporter force;

drop type ut_tfs_junit_reporter force;

drop type ut_event_listener force;

drop type ut_output_reporter_base force;

drop type ut_coverage_reporter_base force;

drop type ut_reporters force;

drop type ut_reporter_base force;

drop type ut_run force;

drop type ut_coverage_options force;

drop type ut_file_mappings force;

drop type ut_file_mapping force;

drop type ut_suite_context force;

drop type ut_suite force;

drop type ut_logical_suite force;

drop type ut_test force;

drop type ut_console_reporter_base force;

drop type ut_executable_test force;

drop type ut_executables force;

drop type ut_executable force;

drop type ut_suite_items force;

drop type ut_suite_item force;

drop type ut_output_table_buffer force;

drop type ut_output_clob_table_buffer force;

drop type ut_output_buffer_base force;

drop table ut_output_buffer_tmp purge;

drop table ut_output_clob_buffer_tmp purge;

drop table ut_output_buffer_info_tmp purge;

drop package ut_session_context;

drop type ut_session_info force;

drop type ut_output_data_rows force;

drop type ut_output_data_row force;

drop type ut_results_counter force;

drop type ut_run_info force;

drop type ut_expectation_results force;

drop type ut_expectation_result force;

drop package ut_event_manager;

drop type ut_event_item force;

drop type ut_reporters_info force;

drop type ut_reporter_info force;

drop type ut_key_anyval_pair force;

drop type ut_key_anyval_pairs force;

drop type ut_key_value_pairs force;

drop type ut_key_value_pair force;

drop type ut_key_anyvalues force;

drop type ut_object_names force;

drop type ut_object_name force;

drop type ut_integer_list force;

drop type ut_varchar2_list force;

drop type ut_varchar2_rows force;

drop package ut_coverage_profiler;

drop package ut_compound_data_helper;

drop package ut_coverage_helper_profiler;

drop type ut_have_count;

drop type ut_compound_data_value;

set echo off
set feedback off
declare
  i        integer := 0;
begin
  dbms_output.put_line('Dropping packages created for 12.2+ ' || upper('&&ut3_owner'));
  for pkg in (
  select object_name, owner
  from all_objects
  where 1 = 1
        and owner = upper('&&ut3_owner')
        and object_type = 'PACKAGE'
        and object_name in ('UT_COVERAGE_HELPER_BLOCK','UT_COVERAGE_BLOCK'))
  loop

    begin

      execute immediate 'drop package ' || pkg.owner || '.' || pkg.object_name;
      dbms_output.put_line('Dropped '|| pkg.object_name);
      i := i + 1;

      exception
      when others then
      dbms_output.put_line('FAILED to drop ' || pkg.object_name);
    end;

  end loop;

  dbms_output.put_line('&&line_separator');
  dbms_output.put_line(i || ' packages dropped');
end;
/
