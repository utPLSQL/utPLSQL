create or replace package body ut_test_runner as

  /*procedure setup_default_reporters as
    reporter ut_suite_reporter;
  begin
    -- if list is initiatized and empty then that's the default that has been choosen
    -- we only initialize the default
    if defaultreporters is null then
      defaultreporters := ut_suite_reporters();

      reporter.package_name := 'ut_dbms_output_reporter';

      if reporter.is_valid() then
        defaultreporters.extend;
        defaultreporters(defaultreporters.last) := reporter;
      end if;
    end if;
  end;*/
	
  function get_default_reporter return ut_suite_reporter is
  begin
    return ut_dbms_output_suite_reporter();
  end get_default_reporter;

  /*procedure execute_tests(a_suite in ut_test_suite, a_reporters in ut_suite_reporters, a_results out ut_suite_results) as
    test_result ut_execution_result;
  begin
    ut_reporter_execution.begin_suite(a_reporters, a_suite);
    a_results := ut_suite_results();
    for i in a_suite.tests.first .. a_suite.tests.last loop
      execute_test(a_suite.tests(i), a_reporters, test_result, true);
      a_results.extend;
      a_results(a_results.last) := test_result;
    end loop;
    ut_reporter_execution.end_suite(a_reporters, a_suite, a_results);
  end;

  procedure execute_tests(a_suite in ut_test_suite, a_results out ut_suite_results) as
  begin
    setup_default_reporters;
    execute_tests(a_suite, defaultreporters, a_results);
  end;

  procedure execute_tests(a_suite in ut_test_suite) as
    results ut_suite_results;
  begin
    execute_tests(a_suite, results);
  end;

  procedure execute_test(a_test in out nocopy ut_single_test, a_reporters in ut_suite_reporters, a_results out ut_execution_result, a_in_suite in boolean default false) as
  begin
    ut_reporter_execution.begin_test(a_reporters, a_test, a_in_suite);
    a_test.execute();
    ut_reporter_execution.end_test(a_reporters, a_test, a_test.test_result, a_in_suite);
  end;

  procedure execute_test(a_test in out nocopy ut_single_test, a_results out ut_execution_result, a_in_suite in boolean default false) as
  begin
    setup_default_reporters;
    execute_test(a_test, ut_suite_reporters(ut_dbms_output_suite_reporter), a_results, a_in_suite);
  end;

  procedure execute_test(a_test in out nocopy ut_single_test, a_in_suite in boolean default false) as
    testresults ut_execution_result;
  begin
    execute_test(a_test, testresults, a_in_suite);
  end;
*/
end;
/
