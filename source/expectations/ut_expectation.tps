create or replace type ut_expectation authid current_user as object(
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
  actual_data         ut_data_value,
  description         varchar2(4000 char),

  --base matcher executors
  member procedure to_(self in ut_expectation, a_matcher ut_matcher),
  member procedure not_to(self in ut_expectation, a_matcher ut_matcher),

  --shortcuts
  member procedure to_be_null(self in ut_expectation),
  member procedure to_be_not_null(self in ut_expectation),
  member procedure not_to_be_null(self in ut_expectation),
  member procedure not_to_be_not_null(self in ut_expectation),

  member procedure to_be_true(self in ut_expectation),
  member procedure to_be_false(self in ut_expectation),
  member procedure not_to_be_true(self in ut_expectation),
  member procedure not_to_be_false(self in ut_expectation),

  -- this is done to provide strong type comparison. other comporators should be implemented in the type-specific classes
  member procedure to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected anydata, a_exclude varchar2, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected anydata, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude varchar2, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null),

  member procedure not_to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected anydata, a_exclude varchar2, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected anydata, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude varchar2, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null),
  member procedure not_to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null),

  member procedure to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 := null),

  member procedure to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 := null),

  member procedure not_to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 := null),

  member procedure not_to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 := null),

  member procedure to_be_between(self in ut_expectation, a_lower_bound date, a_upper_bound date),
  member procedure to_be_between(self in ut_expectation, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained),
  member procedure to_be_between(self in ut_expectation, a_lower_bound number, a_upper_bound number),
  member procedure to_be_between(self in ut_expectation, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained),
  member procedure to_be_between(self in ut_expectation, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained),
  member procedure to_be_between(self in ut_expectation, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained),
  member procedure to_be_between(self in ut_expectation, a_lower_bound varchar2, a_upper_bound varchar2),
  member procedure to_be_between(self in ut_expectation, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained),

  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected date),
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected number),
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure to_be_greater_than(self in ut_expectation, a_expected date),
  member procedure to_be_greater_than(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure to_be_greater_than(self in ut_expectation, a_expected number),
  member procedure to_be_greater_than(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure to_be_greater_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure to_be_greater_than(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure to_be_greater_than(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure to_be_less_or_equal(self in ut_expectation, a_expected date),
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected number),
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure to_be_less_than(self in ut_expectation, a_expected date),
  member procedure to_be_less_than(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure to_be_less_than(self in ut_expectation, a_expected number),
  member procedure to_be_less_than(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure to_be_less_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure to_be_less_than(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure to_be_less_than(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure not_to_be_between(self in ut_expectation, a_lower_bound date, a_upper_bound date),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound number, a_upper_bound number),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound varchar2, a_upper_bound varchar2),
  member procedure not_to_be_between(self in ut_expectation, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained),

  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected date),
  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected number),
  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure not_to_be_greater_or_equal(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure not_to_be_greater_than(self in ut_expectation, a_expected date),
  member procedure not_to_be_greater_than(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure not_to_be_greater_than(self in ut_expectation, a_expected number),
  member procedure not_to_be_greater_than(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure not_to_be_greater_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure not_to_be_greater_than(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure not_to_be_greater_than(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected date),
  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected number),
  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure not_to_be_less_or_equal(self in ut_expectation, a_expected yminterval_unconstrained),

  member procedure not_to_be_less_than(self in ut_expectation, a_expected date),
  member procedure not_to_be_less_than(self in ut_expectation, a_expected dsinterval_unconstrained),
  member procedure not_to_be_less_than(self in ut_expectation, a_expected number),
  member procedure not_to_be_less_than(self in ut_expectation, a_expected timestamp_unconstrained),
  member procedure not_to_be_less_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained),
  member procedure not_to_be_less_than(self in ut_expectation, a_expected timestamp_tz_unconstrained),
  member procedure not_to_be_less_than(self in ut_expectation, a_expected yminterval_unconstrained)
)
not final
/
