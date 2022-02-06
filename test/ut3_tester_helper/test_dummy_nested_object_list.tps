declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_DUMMY_NESTED_OBJECT_LIST';
  if l_exists > 0 then
    execute immediate 'drop type test_dummy_nested_object_list force';
  end if;
end;
/

create or replace type test_dummy_nested_object_list as object (
  first_nested_obj test_dummy_object_list,
  somename varchar2(50)
)
/