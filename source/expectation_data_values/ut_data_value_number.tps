create or replace type ut_data_value_number under ut_data_value(
  value number,
  constructor function ut_data_value_number(self in out nocopy ut_data_value_number, a_value number) return self as result
)
/
