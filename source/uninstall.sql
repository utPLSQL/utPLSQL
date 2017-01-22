prompt Uninstalling UTPLSQL v3 framework
set serveroutput on size unlimited format truncated
set verify off
set define &

spool uninstall.log

define ut3_owner = &1

alter session set current_schema = &&ut3_owner;

drop synonym be_between;

drop synonym match;

drop synonym be_false;

drop synonym be_greater_or_equal;

drop synonym be_greater_than;

drop synonym be_less_or_equal;

drop synonym be_less_than;

drop synonym be_like;

drop synonym be_not_null;

drop synonym be_null;

drop synonym be_true;

drop synonym equal;

drop package ut_coverage_report_html_helper;

drop type ut_coverage_reporter;

drop package ut_coverage;

drop table plsql_profiler_data cascade constraints;
drop table plsql_profiler_units cascade constraints;
drop table plsql_profiler_runs cascade constraints;

drop sequence plsql_profiler_runnumber;

drop package ut_teamcity_reporter_helper;

drop package ut_runner;

drop package ut_runner_helper;

drop package ut_suite_manager;

drop package ut;

drop type ut_expectation_yminterval;

drop type ut_expectation_varchar2;

drop type ut_expectation_timestamp_tz;

drop type ut_expectation_timestamp_ltz;

drop type ut_expectation_timestamp;

drop type ut_expectation_refcursor;

drop type ut_expectation_number;

drop type ut_expectation_dsinterval;

drop type ut_expectation_date;

drop type ut_expectation_clob;

drop type ut_expectation_boolean;

drop type ut_expectation_blob;

drop type ut_expectation_anydata;

drop type ut_expectation;

drop package ut_assert_processor;

drop type ut_match;

drop type ut_be_between;

drop type ut_equal;

drop type ut_be_true;

drop type ut_be_null;

drop type ut_be_not_null;

drop type ut_be_like;

drop type ut_be_greater_or_equal;

drop type ut_be_greater_than;

drop type ut_be_less_or_equal;

drop type ut_be_less_than;

drop type ut_be_false;

drop type ut_matcher;

drop type ut_data_value_yminterval;

drop type ut_data_value_varchar2;

drop type ut_data_value_timestamp_tz;

drop type ut_data_value_timestamp_ltz;

drop type ut_data_value_timestamp;

drop type ut_data_value_number;

drop type ut_data_value_refcursor;

drop type ut_data_value_dsinterval;

drop type ut_data_value_date;

drop type ut_data_value_clob;

drop type ut_data_value_boolean;

drop type ut_data_value_blob;

drop type ut_data_value_anydata;

drop type ut_data_value;

drop package ut_annotations;

drop package ut_metadata;

drop package ut_ansiconsole_helper;

drop package ut_utils;

drop type ut_documentation_reporter;

drop type ut_teamcity_reporter;

drop type ut_xunit_reporter;

drop type ut_event_listener;

drop type ut_reporters;

drop type ut_reporter_base force;

drop type ut_run;

drop type ut_suite ;

drop type ut_logical_suite;

drop type ut_test;

drop type ut_console_reporter_base;

drop type ut_executable;

drop type ut_suite_items;

drop type ut_suite_item;

drop type ut_event_listener_base;

drop type ut_suite_item_base;

drop type ut_output_dbms_pipe;

drop package ut_output_pipe_helper;

drop type ut_output_stream;

drop type ut_output_dbms_output;

drop type ut_output;

drop type ut_results_counter;

drop type ut_assert_results;

drop type ut_assert_result;

drop type ut_varchar2_list;

drop type ut_clob_list;

begin
  for syn in (
    select
      case when owner = 'PUBLIC'
        then 'public synonym '
        else 'synonym ' || owner || '.' end || synonym_name as syn_name,
      table_owner||'.'||table_name as for_object
    from all_synonyms
    where table_owner = upper('&&ut3_owner') and table_owner != owner
  )
  loop
    begin
      execute immediate 'drop '||syn.syn_name;
      dbms_output.put_line('Dropped '||syn.syn_name||' for object '||syn.for_object);
    exception
      when others then
        dbms_output.put_line('FAILED to drop '||syn.syn_name||' for object '||syn.for_object);
    end;
  end loop;
end;
/

spool off
