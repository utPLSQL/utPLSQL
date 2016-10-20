create or replace type ut_data_value_timestamp_tz under ut_data_value(
  value timestamp(9) with time zone,
  constructor function ut_data_value_timestamp_tz(self in out nocopy ut_data_value_timestamp_tz, a_value timestamp_tz_unconstrained) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
