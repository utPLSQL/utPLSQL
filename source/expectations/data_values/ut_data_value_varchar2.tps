create or replace type ut_data_value_varchar2 under ut_data_value(
  data_value varchar2(32767 char),
  constructor function ut_data_value_varchar2(self in out nocopy ut_data_value_varchar2, a_value varchar2) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
