create or replace type ut_be_false under ut_matcher(
  constructor function ut_be_false(self in out nocopy ut_be_false) return self as result,
  overriding member function run_matcher(self in out nocopy ut_be_false, a_actual ut_data_value) return boolean
)
/
