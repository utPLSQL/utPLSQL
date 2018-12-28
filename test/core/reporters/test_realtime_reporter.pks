create or replace package test_realtime_reporter as

  --%suite(ut_realtime_reporter)
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure create_test_suites;
  
  --%test(Report produces expected output)
  procedure report_produces_expected_out;
  
  --%afterall
  procedure remove_test_suites;
end;
/
