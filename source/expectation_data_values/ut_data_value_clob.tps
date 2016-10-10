create or replace type ut_data_value_clob under ut_data_value(
  value clob,
  constructor function ut_data_value_clob(self in out nocopy ut_data_value_clob, a_value clob) return self as result
)
/
