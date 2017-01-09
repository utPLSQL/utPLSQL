create or replace type ut_be_true under ut_matcher(
  constructor function ut_be_true(self in out nocopy ut_be_true) return self as result,
  overriding member function run_matcher(self in out nocopy ut_be_true, a_actual ut_data_value) return boolean
)
/
