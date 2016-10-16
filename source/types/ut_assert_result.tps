create or replace type ut_assert_result force under ut_object
(
  additional_info       varchar2(4000 char),
  expected_type         varchar2(250  char),
  actual_type           varchar2(250  char),
  expected_value_string varchar2(4000 char),
  actual_value_string   varchar2(4000 char),
  message               varchar2(4000 char),
  constructor function ut_assert_result(a_result integer, a_message varchar2, a_name varchar2 default null)
    return self as result,
  constructor function ut_assert_result(a_name varchar2, a_additional_info varchar2, a_result integer, a_expected_type varchar2, a_actual_type varchar2,
    a_expected_value_string varchar2, a_actual_value_string varchar2, a_message varchar2 default null)
    return self as result
)
not final
/
