create or replace type ut_expectation_refcursor under ut_expectation_compound(
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

  constructor function ut_expectation_refcursor(
    self in out nocopy ut_expectation_refcursor, a_actual_data ut_data_value, a_description varchar2
  ) return self as result,

  member function  to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_refcursor,
  member function  to_include(a_expected sys_refcursor) return ut_expectation_refcursor,
  member function  not_to_equal(a_expected sys_refcursor, a_nulls_are_equal boolean := null) return ut_expectation_refcursor,
  member function  to_contain(a_expected sys_refcursor) return ut_expectation_refcursor,
  member function  not_to_include(a_expected sys_refcursor) return ut_expectation_refcursor,
  member function  not_to_contain(a_expected sys_refcursor) return ut_expectation_refcursor,

  overriding member function  include(a_items varchar2) return ut_expectation_refcursor,
  overriding member function  include(a_items ut_varchar2_list) return ut_expectation_refcursor,
  overriding member function  exclude(a_items varchar2) return ut_expectation_refcursor,
  overriding member function  exclude(a_items ut_varchar2_list) return ut_expectation_refcursor,
  overriding member function  unordered return ut_expectation_refcursor,
  overriding member function  join_by(a_columns varchar2) return ut_expectation_refcursor,
  overriding member function  join_by(a_columns ut_varchar2_list) return ut_expectation_refcursor,
  member function  unordered_columns return ut_expectation_refcursor,
  member procedure unordered_columns(self in ut_expectation_refcursor),
  member function  uc return ut_expectation_refcursor,
  member procedure uc(self in ut_expectation_refcursor)
)
final
/
