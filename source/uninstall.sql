prompt Uninstalling utplsql framework

spool uninstall.log

drop package ut_teamcity_reporter_helper;

drop package ut_runner;

drop package ut_suite_manager;

drop package ut_assert;

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

drop type match;

drop type be_between;

drop type equal;

drop type be_true;

drop type be_null;

drop type be_not_null;

drop type be_like;

drop type be_greater_or_equal;

drop type be_greater_than;

drop type be_less_or_equal;

drop type be_less_than;

drop type be_false;

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

drop package ut_utils;

drop type ut_documentation_reporter;

drop type ut_teamcity_reporter;

drop type ut_execution_listener;

drop type ut_reporters;

drop type ut_reporter force;

drop type ut_run;

drop type ut_suite;

drop type ut_test;

drop type ut_executable;

drop type ut_listener_interface;

drop type ut_suite_items;

drop type ut_suite_item;

drop type ut_output_dbms_pipe;

drop package ut_output_pipe_helper;

drop type ut_output_stream;

drop type ut_output_dbms_output;

drop type ut_output;

drop type ut_assert_results;

drop type ut_assert_result;

drop type ut_varchar2_list;

drop type ut_clob_list;

spool off
