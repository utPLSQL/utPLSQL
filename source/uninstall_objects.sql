set echo on
drop synonym be_between;

drop synonym have_count;

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

drop type ut_coverage_cobertura_reporter force;

drop package ut_coverage_report_html_helper;

drop type ut_coverage_html_reporter force;

drop type ut_sonar_test_reporter force;

drop type ut_realtime_reporter force;

drop package ut_coverage;

drop package ut_coverage_helper;

drop view ut_coverage_sources_tmp;

drop table ut_coverage_sources_tmp$;

drop package ut_teamcity_reporter_helper;

drop package ut_runner;

drop type ut_suite_items_info force;

drop type ut_suite_item_info force;

drop package ut_suite_manager;

drop package ut_suite_builder;

drop table ut_suite_cache;

drop sequence ut_suite_cache_seq;

drop table ut_suite_cache_package;

drop table ut_suite_cache_schema;

drop package ut;

drop table ut_dbms_output_cache;

drop type ut_expectation_compound force;

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

drop type ut_data_value_xmltype force;

drop type ut_data_value force;

drop table ut_compound_data_tmp;

drop table ut_compound_data_diff_tmp;

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

drop type ut_output_buffer_base force;

drop view ut_output_buffer_tmp;

drop table ut_output_buffer_tmp$ purge;

drop view ut_output_buffer_info_tmp;

drop table ut_output_buffer_info_tmp$;

drop sequence ut_message_id_seq;

drop type ut_output_data_rows force;

drop type ut_output_data_row force;

drop type ut_results_counter force;

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

drop type ut_object_names force;

drop type ut_object_name force;

drop type ut_integer_list force;

drop type ut_varchar2_list force;

drop type ut_varchar2_rows force;

drop package ut_coverage_profiler;

drop package ut_compound_data_helper;

drop package ut_curr_usr_compound_helper;

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
