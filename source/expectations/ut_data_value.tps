create or replace type ut_data_value as object(
  type         varchar2(250 char),
  is_null      number(1,0),
  value_string varchar2(32767 char)
) not final not instantiable
/
