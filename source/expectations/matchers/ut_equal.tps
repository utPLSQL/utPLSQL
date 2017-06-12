create or replace type ut_equal under ut_comparison_matcher(
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
  nulls_are_equal_flag number(1,0),
  member procedure init(self in out nocopy ut_equal, a_expected ut_data_value, a_nulls_are_equal boolean),
  member function equal_with_nulls( self in ut_equal, a_assert_result boolean, a_actual ut_data_value) return boolean,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected blob, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected boolean, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected clob, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected date, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected number, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude varchar2 := null, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected varchar2, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  overriding member function run_matcher(self in out nocopy ut_equal, a_actual ut_data_value) return boolean,
  overriding member function failure_message(a_actual ut_data_value) return varchar2,
  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2
)
/
