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
  * The expectation result status
  */
  status          integer(1),
  /*
  * User description provided with the expectation
  */
  description     varchar2(32767),
  /*
  * Additional information about the expression used by matcher
  * Used for complex matcher: like, between, ut_match etc.
  */
  message         varchar2(32767),
  /*
  * The information about the line of code that invoked the expectation
  */
  caller_info     varchar2(32767),
  constructor function ut_expectation_result(self in out nocopy ut_expectation_result, a_status integer, a_description varchar2, a_message clob)
    return self as result,
  member function get_result_clob(self in ut_expectation_result) return clob,
  member function get_result_lines(self in ut_expectation_result) return ut_varchar2_list,
  member function result return integer
)
not final
/
