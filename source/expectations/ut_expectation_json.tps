create or replace type ut_expectation_json force under ut_expectation(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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
  matcher             ut_matcher,

  constructor function ut_expectation_json(self in out nocopy ut_expectation_json, a_actual_data ut_data_value, a_description varchar2) return self as result,

  member procedure to_be_empty(self in ut_expectation_json),
  member procedure not_to_be_empty(self in ut_expectation_json),
  member procedure to_have_count(self in ut_expectation_json, a_expected integer),
  member procedure not_to_have_count(self in ut_expectation_json, a_expected integer),
  /*
  member procedure to_contain_text(self in ut_expectation_json, a_expected clob),
  member procedure not_to_contain_text(self in ut_expectation_json, a_expected clob),
  member procedure to_exists(self in ut_expectation_json, a_expected clob),
  member procedure not_to_exists(self in ut_expectation_json, a_expected clob),
  */
  member function  to_equal(a_expected json_element_t , a_nulls_are_equal boolean := null) return ut_expectation_json,
  member function  not_to_equal(a_expected json_element_t , a_nulls_are_equal boolean := null) return ut_expectation_json
)
/
