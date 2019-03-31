create or replace package main_helper is

    gc_success number := ut3.ut_utils.gc_success;
    gc_failure number := ut3.ut_utils.gc_failure;

  procedure execute_autonomous(a_sql varchar2);

  function run_test(a_path varchar2) return clob;

  function get_value(a_variable varchar2) return integer;

  function get_dbms_output_as_clob return clob;
  
  function get_failed_expectations return ut3.ut_varchar2_list;

  function get_failed_expectations(a_pos in number) return varchar2;
  
  function get_failed_expectations_num return number;
  
  procedure clear_expectations;
    
  function table_to_clob(a_results in ut3.ut_varchar2_list) return clob;
  
  function get_warnings return ut3.ut_varchar2_rows;
  
  procedure reset_nulls_equal;
  
  procedure nulls_are_equal(a_nulls_equal boolean := true);
  
  procedure cleanup_annotation_cache;
  
  procedure create_parse_proc_as_ut3$user#;
  
  procedure drop_parse_proc_as_ut3$user#;
  
  procedure parse_dummy_test_as_ut3$user#;
  
  function get_job_count(a_job_name varchar2) return number;
  
  procedure append_to_list(a_list in out nocopy ut3.ut_varchar2_list, a_item varchar2);

  procedure append_to_list(a_list in out nocopy ut3.ut_varchar2_rows, a_item varchar2);

  procedure append_to_list(a_list in out nocopy ut3.ut_varchar2_rows, a_item clob);

  procedure append_to_list(a_list in out nocopy ut3.ut_varchar2_rows, a_items ut3.ut_varchar2_rows);
  
end;
/
