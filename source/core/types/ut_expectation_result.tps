create or replace type ut_expectation_result as object(
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */
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
  * Used for complex matcher: like, between, ut_match etc.
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
  constructor function ut_expectation_result(self in out nocopy ut_expectation_result, a_result integer, a_error_message varchar2)
    return self as result,
  constructor function ut_expectation_result(self in out nocopy ut_expectation_result, a_name varchar2, a_additional_info varchar2, a_error_message varchar2,
    a_result integer, a_expected_type varchar2, a_actual_type varchar2,
    a_expected_value_string varchar2, a_actual_value_string varchar2, a_message varchar2 default null)
    return self as result,
  member function get_result_clob(self in ut_expectation_result) return clob,
  member function get_result_lines(self in ut_expectation_result) return ut_varchar2_list
)
not final
/
