create or replace package test_extended_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters.test_coverage)

  --%test(Coverage is gathered for specified object - extended coverage type)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema - extended coverage type)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file - extended coverage type)
  procedure coverage_for_file;

  --%beforetest(ut3_tester_helper.coverage_helper.create_cov_with_dbms_stats)
  --%aftertest(ut3_tester_helper.coverage_helper.drop_cov_with_dbms_stats)
  --%tags(#1097,#1094)
  --%test(Extended coverage does not fail the test run then tested code calls DBMS_STATS)
  procedure coverage_with_dbms_stats;

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov)
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with schema regex include with ut_run)  
  procedure coverage_regex_include_schema;

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with object regex include with ut_run) 
  procedure coverage_regex_include_object;

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with schema regex exclude with ut_run) 
  procedure coverage_regex_exclude_schema;  

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with object regex exclude with ut_run) 
  procedure coverage_regex_exclude_object;  

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with schema regex include without ut_run) 
  procedure cove_rgx_inc_schema_norun;

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with object regex include without ut_run) 
  procedure cove_rgx_inc_object_norun;

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with schema regex exclude without ut_run) 
  procedure cove_rgx_exc_schema_norun;

  --%beforetest(ut3_tester_helper.coverage_helper.create_regex_dummy_cov) 
  --%aftertest(ut3_tester_helper.coverage_helper.drop_regex_dummy_cov)
  --%test(Collect coverage for objects with object regex exclude without ut_run) 
  procedure cove_rgx_exc_object_norun;

end;
/
