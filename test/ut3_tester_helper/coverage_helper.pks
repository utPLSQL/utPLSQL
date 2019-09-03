create or replace package coverage_helper is

  type prof_runs_tab is table of ut3.plsql_profiler_runs%rowtype;
  
  function get_mock_proftab_run_id return integer;

  procedure setup_mock_coverage_id;

  procedure mock_coverage_data(a_user in varchar2);

  procedure cleanup_dummy_coverage;

  procedure setup_dummy_coverage;

  --Profiler coverage
  procedure create_dummy_coverage_package;
  procedure create_dummy_coverage_test;
  procedure grant_exec_on_cov;
  procedure mock_profiler_coverage_data(a_run_id integer,a_user in varchar2);
  procedure drop_dummy_coverage_pkg;  

  procedure create_dummy_coverage_test_1;
  procedure drop_dummy_coverage_test_1; 

  --Block coverage
  procedure create_dummy_12_2_cov_pck;
  procedure create_dummy_12_2_cov_test;
  procedure mock_block_coverage_data(a_run_id integer,a_user in varchar2);
  procedure grant_exec_on_12_2_cov;

  procedure set_develop_mode;
  
end;
/
