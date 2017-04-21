create or replace type ut_expectation authid current_user as object(
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
  actual_data         ut_data_value,
  message             varchar2(4000 char),
  final member procedure add_expectation_result( self in ut_expectation, a_expectation_result boolean, a_matcher_name varchar2,
  a_expectation_info varchar2, a_error_message varchar2, a_expected_value_string in varchar2 := null, a_expected_data_type varchar2 := null),
  final member procedure to_(self in ut_expectation, a_matcher ut_matcher),
  final member procedure not_to(self in ut_expectation, a_matcher ut_matcher),
  final member procedure to_be_null(self in ut_expectation),
  final member procedure to_be_not_null(self in ut_expectation),

  -- this is done to provide strong type comparison. other comporators should be implemented in the type-specific classes
  member procedure to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null)
)
not final not instantiable
/
