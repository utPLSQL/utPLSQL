create or replace package coverage_helper is

  g_run_id integer;
  
  type prof_runs_tab is table of ut3.plsql_profiler_runs%rowtype;
  
  function get_mock_run_id return integer;
  function get_mock_block_run_id return integer;
  procedure cleanup_dummy_coverage(a_run_id in integer);
  procedure mock_coverage_data(a_run_id integer,a_user in varchar2);

  --Profiler coveage
  procedure create_dummy_coverage_package;
  procedure create_dummy_coverage_test;
  procedure grant_exec_on_cov;
  procedure mock_profiler_coverage_data(a_run_id integer,a_user in varchar2);
  procedure drop_dummy_coverage_pkg;  
    
  --Block coverage
  procedure create_dummy_12_2_cov_pck;
  procedure create_dummy_12_2_cov_test;
  procedure mock_block_coverage_data(a_run_id integer,a_user in varchar2);
  procedure cleanup_dummy_coverage(a_block_id in integer, a_prof_id in integer);
  procedure grant_exec_on_12_2_cov;
  
end;
/
