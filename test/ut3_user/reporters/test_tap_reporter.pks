create or replace package test_tap_reporter as

  --%suite(ut_tap_reporter)
  --%suitepath(utplsql.test_user.reporters)

  --%test(Simple succeeding test)
  procedure simple_succeeding_test;

  --%test(Simple failing test)
  procedure simple_failing_test;

  --%test(Simple erroring test)
  procedure simple_erroring_test;

  --%test(Skipped test)
  procedure disabled_test;

  --%test(Skipped test without description)
  procedure disabled_test_no_description;

  --%test(Multiple tests with different outcome)
  procedure multiple_tests_different_outcome;

end test_tap_reporter;
/