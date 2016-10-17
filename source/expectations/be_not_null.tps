create or replace type be_not_null under ut_expectation(
  constructor function be_not_null(self in out nocopy be_not_null) return self as result,
  overriding member function run_expectation(self in out nocopy be_not_null, a_actual ut_data_value) return boolean
)
/
