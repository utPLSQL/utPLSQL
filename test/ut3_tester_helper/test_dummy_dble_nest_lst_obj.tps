declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_DUMMY_DBLE_NEST_LST_OBJ';
  if l_exists > 0 then
    execute immediate 'drop type test_dummy_dble_nest_lst_obj force';
  end if;
end;
/

CREATE TYPE test_dummy_dble_nest_lst_obj AS OBJECT 
( 
  some_number_id NUMBER, 
  some_name VARCHAR2 (25), 
  dummy_list test_dummy_double_nested_list 
);
/