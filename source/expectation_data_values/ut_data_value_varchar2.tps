create or replace type ut_data_value_varchar2 under ut_data_value(
  value varchar2(32767 char),
  constructor function ut_data_value_varchar2(self in out nocopy ut_data_value_varchar2, a_value varchar2) return self as result
)
/
