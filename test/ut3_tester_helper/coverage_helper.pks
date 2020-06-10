create or replace package coverage_helper is

  type prof_runs_tab is table of ut3_develop.plsql_profiler_runs%rowtype;
  
  procedure setup_mock_coverage_id;

  procedure mock_coverage_data(a_user in varchar2);

  procedure cleanup_long_name_package;

  procedure setup_long_name_package;

  --Profiler coverage
  procedure create_dummy_coverage_package;
  procedure create_dummy_coverage_test;
  procedure grant_exec_on_cov;
  procedure mock_profiler_coverage_data(a_run_id integer,a_user in varchar2);
  procedure drop_dummy_coverage_pkg;  

  procedure create_dummy_coverage_test_1;
  procedure drop_dummy_coverage_test_1; 

  --Block coverage
  procedure mock_block_coverage_data(a_run_id integer,a_user in varchar2);

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
