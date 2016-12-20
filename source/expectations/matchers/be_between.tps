create or replace type be_between under ut_matcher
(
  lower_bound ut_data_value,
  upper_bound ut_data_value,
  
  member procedure init(self in out nocopy be_between, a_lower_bound ut_data_value, a_upper_bound ut_data_value),

  constructor function be_between(self in out nocopy be_between, a_lower_bound date, a_upper_bound date)
    return self as result,
  constructor function be_between(self in out nocopy be_between, a_lower_bound number, a_upper_bound number)
    return self as result,
  constructor function be_between(self in out nocopy be_between, a_lower_bound varchar2, a_upper_bound varchar2)
    return self as result,    
  constructor function be_between(self in out nocopy be_between, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained)
    return self as result,
  constructor function be_between(self in out nocopy be_between, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)
    return self as result,
  constructor function be_between(self in out nocopy be_between, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained)
    return self as result,
  constructor function be_between(self in out nocopy be_between, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained)
    return self as result,
  constructor function be_between(self in out nocopy be_between, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)
    return self as result,

  overriding member function run_matcher(self in out nocopy be_between, a_actual ut_data_value) return boolean
)
/
