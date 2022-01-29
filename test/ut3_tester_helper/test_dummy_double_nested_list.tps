declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_DUMMY_DOUBLE_NESTED_LIST';
  if l_exists > 0 then
    execute immediate 'drop type test_dummy_double_nested_list force';
  end if;
end;
/

CREATE TYPE test_dummy_double_nested_list AS
    TABLE OF test_dummy_nested_object_list;
/
