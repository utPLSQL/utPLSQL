create or replace type ut_expectation_compound force under ut_expectation(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

  constructor function ut_expectation_compound(self in out nocopy ut_expectation_compound, a_actual_data ut_data_value, a_description varchar2) return self as result,

  member procedure to_be_empty(self in ut_expectation_compound),
  member procedure not_to_be_empty(self in ut_expectation_compound),
  member procedure to_have_count(self in ut_expectation_compound, a_expected integer),
  member procedure not_to_have_count(self in ut_expectation_compound, a_expected integer),

  member function  to_equal(a_expected anydata, a_nulls_are_equal boolean := null) return ut_expectation_compound,
  member function  not_to_equal(a_expected anydata, a_nulls_are_equal boolean := null) return ut_expectation_compound,
  member function  to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_compound,
  member function  not_to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_compound,
  member function  to_contain(a_expected sys_refcursor) return ut_expectation_compound,
  member function  not_to_contain(a_expected sys_refcursor) return ut_expectation_compound,
  member function  to_contain(a_expected anydata) return ut_expectation_compound,
  member function  not_to_contain(a_expected anydata) return ut_expectation_compound,

  member function  include(a_items varchar2) return ut_expectation_compound,
  member function  include(a_items ut_varchar2_list) return ut_expectation_compound,
  member procedure include(self in ut_expectation_compound, a_items varchar2),
  member procedure include(self in ut_expectation_compound, a_items ut_varchar2_list),
  member function  exclude(a_items varchar2) return ut_expectation_compound,
  member function  exclude(a_items ut_varchar2_list) return ut_expectation_compound,
  member procedure exclude(self in ut_expectation_compound, a_items varchar2),
  member procedure exclude(self in ut_expectation_compound, a_items ut_varchar2_list),
  member function  unordered return ut_expectation_compound,
  member procedure unordered(self in ut_expectation_compound),
  member function  join_by(a_columns varchar2) return ut_expectation_compound,
  member function  join_by(a_columns ut_varchar2_list) return ut_expectation_compound,
  member procedure join_by(self in ut_expectation_compound, a_columns varchar2),
  member procedure join_by(self in ut_expectation_compound, a_columns ut_varchar2_list),
  
  member function  unordered_columns return ut_expectation_compound,
  member procedure unordered_columns(self in ut_expectation_compound),
  member function  uc return ut_expectation_compound,
  member procedure uc(self in ut_expectation_compound)
)
/
