create or replace type ut_data_value_blob under ut_data_value(
  value blob,
  constructor function ut_data_value_blob(self in out nocopy ut_data_value_blob, a_value blob) return self as result
)
/
