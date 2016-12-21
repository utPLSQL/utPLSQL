create or replace type ut_data_value_dsinterval under ut_data_value(
  datavalue dsinterval_unconstrained,
  constructor function ut_data_value_dsinterval(self in out nocopy ut_data_value_dsinterval, a_value dsinterval_unconstrained) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
