create or replace type ut_data_value_blob under ut_data_value(
  datavalue blob,
  constructor function ut_data_value_blob(self in out nocopy ut_data_value_blob, a_value blob) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
