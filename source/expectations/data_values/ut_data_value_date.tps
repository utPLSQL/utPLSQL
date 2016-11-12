create or replace type ut_data_value_date under ut_data_value(
  datavalue date,
  constructor function ut_data_value_date(self in out nocopy ut_data_value_date, a_value date) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
