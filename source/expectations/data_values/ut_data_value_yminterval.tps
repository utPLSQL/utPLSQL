create or replace type ut_data_value_yminterval under ut_data_value(
  data_value yminterval_unconstrained,
  constructor function ut_data_value_yminterval(self in out nocopy ut_data_value_yminterval, a_value yminterval_unconstrained) return self as result,
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2
)
/
