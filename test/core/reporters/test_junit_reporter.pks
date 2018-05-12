create or replace package test_junit_reporter as

  --%suite(ut_junit_reporter)
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure create_a_test_package;

  --%test(Escapes special characters from test and suite description)
  procedure escapes_special_chars;

  --%test(Reports only failed expectations and exceptions)
  procedure reports_only_failed_or_errored;

  --%test(Xunit Backward Compatibility - Reports only failed expectations and exceptions)
  procedure reports_xunit_only_fail_or_err;
  
  --%test(Reports failed line of test)
  procedure reports_failed_line;

  --%test(Check that classname is returned correct suite)
  procedure check_classname_suite;

  --%test(Check that classname is returned correct suitepath)
  procedure check_classname_suitepath;

  --%test(Reports duration according to XML specification for numbers)
  procedure check_nls_number_formatting;
  
  --%test(Report on test without description)
  procedure report_test_without_desc;
  
  --%test(Report on suite without description)
  procedure report_suite_without_desc;
  
  --%test(Report produces expected output)
  procedure reporort_produces_expected_out;
  
  --%test( Test for bug #659)
  procedure check_classname_is_populated;

  --%afterall
  procedure remove_test_package;
end;
/
