create or replace type ut_object as object
(
  name varchar2(250 char),
  --execution_result ut_execution_result,
	result integer(1),
  object_type integer(1), --0 - assert, 1 -- test, 2 -- suite
	
	member function result_to_char return varchar2
) not final not instantiable
/
