create or replace package test_documentation_reporter as

  --%suite(ut_documentation_reporter)
  --%suitepath(utplsql.core.reporters)

  --%test(Report produces expected output)
  procedure report_produces_expected_out;

end;
/
