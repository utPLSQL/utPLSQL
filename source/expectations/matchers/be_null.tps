create or replace type be_null under ut_matcher(
  constructor function be_null(self in out nocopy be_null) return self as result,
  overriding member function run_matcher(self in out nocopy be_null, a_actual ut_data_value) return boolean
)
/
