create or replace type ut_data_value_anydata 
authid current_user
under ut_data_value(
  datavalue anydata,
  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
