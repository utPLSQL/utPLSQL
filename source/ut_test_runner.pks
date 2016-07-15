create or replace package ut_test_runner
as
/*
  package: ut_test_runner
  Executes a single test or suite of tests, used *internally*. 
  */

/**
* default test reporters 
* used if not specified in execute_tests or execute_test call
*/
    --todo: decide what the default reporter should be, most likely won't put reporter management here.
    defaultreporters ut_types.test_suite_reporters;
    
    procedure setup_default_reporters; 
    
    procedure execute_tests(a_suite in ut_types.test_suite, a_reporters in ut_types.test_suite_reporters, a_results out ut_types.test_suite_results);
    procedure execute_tests(a_suite in ut_types.test_suite, a_results out ut_types.test_suite_results);
    procedure execute_tests(a_suite in ut_types.test_suite);

    procedure execute_test(a_test in ut_types.single_test, a_reporters in ut_types.test_suite_reporters, a_results out ut_types.test_execution_result,a_in_suite in boolean default false);
    procedure execute_test(a_test in ut_types.single_test, a_results out ut_types.test_execution_result,a_in_suite in boolean default false);
    procedure execute_test(a_test in ut_types.single_test,a_in_suite in boolean default false);



end; 