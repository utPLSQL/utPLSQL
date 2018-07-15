create or replace package test_teamcity_reporter as

  --%suite(ut_teamcity_reporter)
  --%suitepath(utplsql.core.reporters)

  --%test(Report produces expected output)
  procedure report_produces_expected_out;

end;
/
