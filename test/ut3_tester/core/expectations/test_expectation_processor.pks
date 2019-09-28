create or replace package test_expectation_processor is

  --%suite(expectation_processor)
  --%suitepath(utplsql.ut3_tester.core.expectations)

  --%beforeall(ut3_tester_helper.main_helper.set_ut_run_context)
  --%afterall(ut3_tester_helper.main_helper.clear_ut_run_context)

  --%context(who_called_expectation_in_test)

  --%test(parses stack trace containing 0x and returns objects and line that called expectation)
  procedure who_called_expectation_0x;

  --%test(parses stack trace and returns objects and line that called expectation)
  procedure who_called_expectation;

  --%test(parses stack trace for Windows DB os - regression for #1000)
  procedure who_call_expectation_win_stack;

  --%endcontext

end;
/
