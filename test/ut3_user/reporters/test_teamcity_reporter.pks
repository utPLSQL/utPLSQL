create or replace package test_teamcity_reporter as

  --%suite(ut_teamcity_reporter)
  --%suitepath(utplsql.test_user.reporters)

  --%beforeall
  procedure create_a_test_package;

  --%test(Report produces expected output)
  procedure report_produces_expected_out;

  --%test(Escapes special characters)
  procedure escape_special_chars;

  --%test(Trims output so it fits into 4000 chars)
  procedure trims_long_output;

  --%test(Reports failures on multiple expectations)
  procedure report_multiple_expectations;

  --%test(Reports failures on multiple expectations)
  procedure report_multiple_expect_on_err;

  --%afterall
  procedure remove_test_package;

end;
/
