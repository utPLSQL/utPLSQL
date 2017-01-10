create or replace type ut_equal under ut_matcher(
  nulls_are_equal_flag number(1,0),
  member procedure init(self in out nocopy ut_equal, a_expected ut_data_value, a_nulls_are_equal boolean),
  member function equal_with_nulls( self in ut_equal, a_assert_result boolean, a_actual ut_data_value) return boolean,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected anydata, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected blob, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected boolean, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected clob, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected date, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected number, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected sys_refcursor, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected varchar2, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  constructor function ut_equal(self in out nocopy ut_equal, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  overriding member function run_matcher(self in out nocopy ut_equal, a_actual ut_data_value) return boolean
)
/
