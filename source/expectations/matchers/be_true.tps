create or replace type be_true under ut_matcher(
  constructor function be_true(self in out nocopy be_true) return self as result,
  overriding member function run_matcher(self in out nocopy be_true, a_actual ut_data_value) return boolean
)
/
