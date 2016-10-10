create or replace type ut_data_value_timestamp_ltz under ut_data_value(
  value timestamp(9) with local time zone,
  constructor function ut_data_value_timestamp_ltz(self in out nocopy ut_data_value_timestamp_ltz, a_value timestamp_ltz_unconstrained) return self as result
)
/
