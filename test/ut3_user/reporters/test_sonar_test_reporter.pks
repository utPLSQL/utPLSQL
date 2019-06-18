create or replace package test_sonar_test_reporter as

  --%suite(ut_sonar_test_reporter)
  --%suitepath(utplsql.test_user.reporters)

  --%test(Report produces expected output)
  procedure report_produces_expected_out;
  
  --%test(Includes XML header with encoding when encoding provided)
  procedure check_encoding_included;

  --%test( Validate that fail with special char are escaped )
  procedure check_failure_escaped;

end;
/
