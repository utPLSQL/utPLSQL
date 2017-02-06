create or replace type ut_data_value authid current_user  as object(
  data_type         varchar2(250 char),
  not instantiable member function is_null return boolean,
  not instantiable member function to_string return varchar2
) not final not instantiable
/
