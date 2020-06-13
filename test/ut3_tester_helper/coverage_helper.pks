create or replace package coverage_helper is

  procedure create_long_name_package;
  procedure drop_long_name_package;

  --Profiler coverage
  procedure create_dummy_coverage;
  procedure drop_dummy_coverage;

  procedure create_dummy_coverage_test_1;
  procedure drop_dummy_coverage_test_1; 

  procedure set_develop_mode;

  procedure run_standalone_coverage(a_coverage_run_id raw, a_input integer);
  procedure run_coverage_job(a_coverage_run_id raw, a_input integer);
  procedure create_coverage_pkg;
  procedure drop_coverage_pkg;

  function run_tests_as_job( a_run_command varchar2 ) return clob;
  function run_code_as_job( a_plsql_block varchar2 ) return clob;
  procedure create_test_results_table;
  procedure drop_test_results_table;

end;
/
