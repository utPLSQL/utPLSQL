create or replace package test_tap_reporter as

  --%suite(ut_tap_reporter)
  --%suitepath(utplsql.test_user.reporters)

  --%test(Simple succeeding test)
  procedure simple_succeeding_test;

  --%test(Simple failing test)
  procedure simple_failing_test;

  --%test(Simple erroring test)
  procedure simple_erroring_test;

end test_tap_reporter;
/