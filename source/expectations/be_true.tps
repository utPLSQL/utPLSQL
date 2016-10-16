create or replace type be_true under ut_expectation(
  constructor function be_true(self in out nocopy be_true) return self as result,
  overriding member function run_expectation(self in out nocopy be_true, a_actual ut_data_value) return boolean
)
/
