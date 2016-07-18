create or replace type ut_complex_suite_reporter under ut_suite_reporter
(
  -- Author  : PAVEL.KAPLYA
  -- Created : 19.07.2016 11:36:53
  -- Purpose : 
  
  -- Attributes
  reporters ut_suite_reporters,
  
  -- Member functions and procedures
	constructor function ut_complex_suite_reporter return self as result,
  member procedure add_reporter(self in out nocopy ut_complex_suite_reporter, a_reporter ut_suite_reporter),
	
  overriding member procedure begin_suite(self in ut_complex_suite_reporter, a_suite_name in varchar2),
  overriding member procedure end_suite(self in ut_complex_suite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result),
  overriding member procedure begin_test(self in ut_complex_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params),
  overriding member procedure end_test(self in ut_complex_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list)
	
) not final
/
