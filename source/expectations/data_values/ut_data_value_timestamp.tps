create or replace type ut_data_value_timestamp under ut_data_value(
  datavalue timestamp(9),
  constructor function ut_data_value_timestamp(self in out nocopy ut_data_value_timestamp, a_value timestamp_unconstrained) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
