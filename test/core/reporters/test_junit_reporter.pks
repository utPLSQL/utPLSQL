create or replace package test_junit_reporter as

  --%suite(ut_junit_reporter)
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure crate_a_test_package;

  --%test(Escapes special characters from test and suite description)
  procedure escapes_special_chars;

  --%test(Reports only failed expectations and exceptions)
  procedure reports_only_failed_or_errored;

  --%test(Reports failed line of test)
  procedure reports_failed_line;

  --%test(Check that classname is returned correct suite)
  procedure check_classname_suite;

  --%test(Check that explicit parameter display correct version 4)
  procedure check_reporter_version_four;
  
  --%test(Check that explicit parameter display correct version 1)
  procedure check_reporter_version_one;
  
  --%test(Check that classname is returned correct suitepath)
  procedure check_classname_suitepath;

  --%test(Reports duration according to XML specification for numbers)
  procedure check_nls_number_formatting;

  --%afterall
  procedure remove_test_package;
end;
/
