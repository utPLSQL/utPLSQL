create or replace type ut_data_value_number under ut_data_value(
  data_value number,
  constructor function ut_data_value_number(self in out nocopy ut_data_value_number, a_value number) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
