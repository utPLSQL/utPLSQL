create or replace type be_less_than under ut_matcher(  
  member procedure init(self in out nocopy be_less_than, a_expected ut_data_value),
  constructor function be_less_than(self in out nocopy be_less_than, a_expected date) return self as result,
  constructor function be_less_than(self in out nocopy be_less_than, a_expected number) return self as result,
  constructor function be_less_than(self in out nocopy be_less_than, a_expected timestamp_unconstrained) return self as result,
  constructor function be_less_than(self in out nocopy be_less_than, a_expected timestamp_tz_unconstrained) return self as result,
  constructor function be_less_than(self in out nocopy be_less_than, a_expected timestamp_ltz_unconstrained) return self as result,
  constructor function be_less_than(self in out nocopy be_less_than, a_expected yminterval_unconstrained) return self as result,
  constructor function be_less_than(self in out nocopy be_less_than, a_expected dsinterval_unconstrained) return self as result,  
  overriding member function run_matcher(self in out nocopy be_less_than, a_actual ut_data_value) return boolean  
)
/
