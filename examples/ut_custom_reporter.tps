create or replace type ut_custom_reporter under ut_dbms_output_suite_reporter
(
  lvl integer,
  tab_size integer,

-- Member functions and procedures
  constructor function ut_custom_reporter(a_tab_size integer default 4) return self as result,
  member function tab(self in ut_custom_reporter) return varchar2,
  overriding member procedure print(msg varchar2),
  overriding member procedure begin_suite(self in out nocopy ut_custom_reporter, a_suite_name in varchar2),
  overriding member procedure begin_test(self in out nocopy ut_custom_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params),
  overriding member procedure end_test(self in out nocopy ut_custom_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list),
  overriding member procedure end_suite(self in out nocopy ut_custom_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result)
)
not final
/
