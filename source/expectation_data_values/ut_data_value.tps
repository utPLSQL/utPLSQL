create or replace type ut_data_value as object(
  type         varchar2(250 char),
  is_null      number(1,0),
  value_string varchar2(32767 char),
  final member procedure init(self in out nocopy ut_data_value, a_type varchar2, a_is_null number, a_value_string varchar2)
) not final not instantiable
/
