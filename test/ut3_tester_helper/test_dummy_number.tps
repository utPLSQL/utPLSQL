declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_DUMMY_NUMBER';
  if l_exists > 0 then
    execute immediate 'drop type test_dummy_number force';
  end if;
end;
/

create or replace type test_dummy_number as object (
  id number
)
/
