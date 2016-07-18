create or replace type ut_suite_reporter force as object
(
  name varchar2(250 char),
	

  not instantiable member procedure begin_suite(self in ut_suite_reporter, a_suite_name in varchar2),
  not instantiable member procedure end_suite(self in ut_suite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result),
  not instantiable member procedure begin_test(self in ut_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params),
  not instantiable member procedure end_test(self in ut_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list)

)
not instantiable not final
/
