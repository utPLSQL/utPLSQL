create or replace type ut_data_value_boolean under ut_data_value(
  value number(1,0), --holds int representation of boolean
  constructor function ut_data_value_boolean(self in out nocopy ut_data_value_boolean, a_value boolean) return self as result
)
/
