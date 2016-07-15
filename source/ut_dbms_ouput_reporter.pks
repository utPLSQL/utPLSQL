create or replace package ut_dbms_output_reporter
as
  procedure begin_suite (a_suite in ut_types.test_suite);
  
  procedure end_suite (a_suite in ut_types.test_suite, a_results in ut_types.test_suite_results);
  
  procedure begin_test(a_test in ut_types.single_test,a_in_suite in boolean);
  
  procedure end_test(a_test in ut_types.single_test, a_result ut_types.test_execution_result,a_in_suite in boolean);
  
end;