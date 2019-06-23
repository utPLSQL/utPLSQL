create or replace package test_extended_coverage is

  --%suite
  --%suitepath(utplsql.test_user.reporters)

  --%beforeall(ut3_tester_helper.coverage_helper.setup_dummy_coverage)

  --%afterall(ut3_tester_helper.coverage_helper.cleanup_dummy_coverage)

  --%test(Coverage is gathered for specified object - extended coverage type)
  procedure coverage_for_object;

  --%test(Coverage is gathered for specified schema - extended coverage type)
  procedure coverage_for_schema;

  --%test(Coverage is gathered for specified file - extended coverage type)
  procedure coverage_for_file;
  
end;
/
