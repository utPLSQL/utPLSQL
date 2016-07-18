create or replace package ut_test_runner as
  /*
  package: ut_test_runner
  Executes a single test or suite of tests, used *internally*.
  */

  /**
  * default test reporters
  * used if not specified in execute_tests or execute_test call
  */
  --todo: decide what the default reporter should be, most likely won't put reporter management here.
  --defaultreporters ut_suite_reporters;

  --procedure setup_default_reporters;
  function get_default_reporter return ut_suite_reporter;

  /*
  procedure execute_tests(a_suite in out nocopy ut_test_suite, a_reporter in ut_suite_reporter);
  procedure execute_tests(a_suite in out nocopy ut_test_suite);

  procedure execute_test(a_test in out nocopy ut_single_test, a_reporter in ut_suite_reporter, a_in_suite in boolean default false);
  procedure execute_test(a_test in out nocopy ut_single_test, a_in_suite in boolean default false);
	*/
end;
/
