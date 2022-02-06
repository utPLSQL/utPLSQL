declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_DUMMY_OBJECT_LIST';
  if l_exists > 0 then
    execute immediate 'drop type test_dummy_object_list force';
  end if;
end;
/

create or replace type test_dummy_object_list as table of test_dummy_object
/
