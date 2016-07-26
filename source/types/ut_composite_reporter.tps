create or replace type ut_composite_reporter under ut_suite_reporter
(
  reporters ut_reporters_list,

  constructor function ut_composite_reporter(the_reporters ut_reporters_list default ut_reporters_list())
    return self as result,
  member procedure add_reporter(self in out nocopy ut_composite_reporter, a_reporter ut_suite_reporter),
  member procedure remove_reporter(self in out nocopy ut_composite_reporter, an_index pls_integer),

  overriding member procedure begin_suite(self in out nocopy ut_composite_reporter, a_suite_name in varchar2),
  overriding member procedure begin_test(self in out nocopy ut_composite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params),
  overriding member procedure end_test(self in out nocopy ut_composite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list),
  overriding member procedure end_suite(self in out nocopy ut_composite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result)

)
not final
/
