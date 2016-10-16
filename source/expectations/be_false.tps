create or replace type be_false under ut_expectation(
  constructor function be_false(self in out nocopy be_false) return self as result,
  overriding member function run_expectation(a_actual ut_data_value) return boolean
)
/
