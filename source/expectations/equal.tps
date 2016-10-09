create or replace type equal under ut_expectation(
  nulls_are_equal number(1,0),
  constructor function equal(self in out nocopy equal, a_expected varchar2, a_nulls_are_equal boolean := null) return self as result,
  constructor function equal(self in out nocopy equal, a_expected number, a_nulls_are_equal boolean := null) return self as result,
  constructor function equal(self in out nocopy equal, a_expected clob, a_nulls_are_equal boolean := null) return self as result,
  constructor function equal(self in out nocopy equal, a_expected blob, a_nulls_are_equal boolean := null) return self as result,
  constructor function equal(self in out nocopy equal, a_expected date, a_nulls_are_equal boolean := null) return self as result,
  constructor function equal(self in out nocopy equal, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) return self as result,
  overriding member function run_expectation(self in equal, a_actual ut_data_value_varchar2) return ut_assert_result,
  overriding member function run_expectation(self in equal, a_actual ut_data_value_number) return ut_assert_result,
  overriding member function run_expectation(self in equal, a_actual ut_data_value_clob) return ut_assert_result,
  overriding member function run_expectation(self in equal, a_actual ut_data_value_blob) return ut_assert_result,
  overriding member function run_expectation(self in equal, a_actual ut_data_value_date) return ut_assert_result,
  overriding member function run_expectation(self in equal, a_actual ut_data_value_timestamp) return ut_assert_result
)
/
