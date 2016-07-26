create or replace type ut_object as object
(
  name varchar2(250 char),
  execution_result ut_execution_result,
  object_type integer(1) --0 - assert, 1 -- test, 2 -- suite
) not final not instantiable
/
