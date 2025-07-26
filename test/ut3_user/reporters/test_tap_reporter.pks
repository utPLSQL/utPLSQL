create or replace package test_tap_reporter as

  --%suite(ut_tap_reporter)
  --%suitepath(utplsql.test_user.reporters)

  --%beforeall
  procedure compile_tests;

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

  --%test(Escape special characters in suite name)
  procedure escape_suite_name;

  --%test(Escape multiple special characters in test name)
  procedure escape_multiple_characters_test_name;

  --%test(Disabled Test with special characters in disable reason)
  procedure special_characters_in_deisabled_reason;


  --%afterall
  procedure drop_help_tests;

end test_tap_reporter;
/