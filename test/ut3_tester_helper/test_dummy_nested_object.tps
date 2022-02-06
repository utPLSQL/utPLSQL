declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_DUMMY_NESTED_OBJECT';
  if l_exists > 0 then
    execute immediate 'drop type test_dummy_nested_object force';
  end if;
end;
/

create or replace type test_dummy_nested_object as object (
  first_nested_obj test_dummy_object,
  sec_nested_obj test_dummy_object
)
/