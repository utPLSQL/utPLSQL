create or replace package coverage_helper is

  function block_coverage_available return boolean;

  function covered_package_name return varchar2;

  function substitute_covered_package( a_text varchar2, a_substitution varchar2 := '{p}' ) return varchar2;

  procedure set_develop_mode;

  procedure create_dummy_coverage;
  procedure drop_dummy_coverage;

  procedure create_dummy_coverage_1;
  procedure drop_dummy_coverage_1;

  procedure create_regex_dummy_cov;
  procedure drop_regex_dummy_cov;

  procedure create_regex_dummy_cov_schema;
  procedure drop_regex_dummy_cov_schema;

  procedure create_cov_with_dbms_stats;
  procedure drop_cov_with_dbms_stats;

  procedure run_standalone_coverage(a_coverage_run_id raw, a_input integer);
  procedure run_coverage_job(a_coverage_run_id raw, a_input integer);

  function run_tests_as_job( a_run_command varchar2 ) return clob;
  function run_code_as_job( a_plsql_block varchar2 ) return clob;
  procedure create_test_results_table;
  procedure drop_test_results_table;

  procedure drop_dup_object_name;
  procedure create_dup_object_name;

end;
/
