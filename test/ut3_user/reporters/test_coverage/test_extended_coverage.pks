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
  
end;
/
