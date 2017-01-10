create or replace type ut_be_not_null under ut_matcher(
  constructor function ut_be_not_null(self in out nocopy ut_be_not_null) return self as result,
  overriding member function run_matcher(self in out nocopy ut_be_not_null, a_actual ut_data_value) return boolean
)
/
