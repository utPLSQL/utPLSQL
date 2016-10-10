create or replace type ut_data_value_date under ut_data_value(
  value date,
  constructor function ut_data_value_date(self in out nocopy ut_data_value_date, a_value date) return self as result
)
/
