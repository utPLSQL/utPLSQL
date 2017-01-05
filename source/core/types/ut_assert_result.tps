create or replace type ut_assert_result as object
(
  /*
  * name of the matcher that was used to check the expectation
  */
  matcher_name varchar2(250 char),
  /*
  * The expectation result
  */
  result integer(1),
  /*
  * Additional information about the expression used by matcher
  * Used for complex matcher: like, between, match etc.
  */
  additional_info       varchar2(4000 char),
  /*
  * Data type name for the expected value
  */
  expected_type         varchar2(250  char),
  /*
  * Data type name for the actual value
  */
  actual_type           varchar2(250  char),
  /*
  * String representation of expected value
  */
  expected_value_string varchar2(4000 char),
  /*
  * String representation of actual value
  */
  actual_value_string   varchar2(4000 char),
  /*
  * User message (description) provided with the expectation
  */
  message               varchar2(4000 char),
  /*
  * Error message that was captured.
  */
  error_message         varchar2(4000 char),
  /*
  * The information about the line of code that invoked the expectation
  */
  caller_info           varchar2(4000 char),
  constructor function ut_assert_result(self in out nocopy ut_assert_result, a_result integer, a_error_message varchar2)
    return self as result,
  constructor function ut_assert_result(self in out nocopy ut_assert_result, a_name varchar2, a_additional_info varchar2, a_error_message varchar2,
    a_result integer, a_expected_type varchar2, a_actual_type varchar2,
    a_expected_value_string varchar2, a_actual_value_string varchar2, a_message varchar2 default null)
    return self as result,
  member function get_result_clob(self in ut_assert_result) return clob,
  member function get_result_lines(self in ut_assert_result) return ut_varchar2_list
)
not final
/
