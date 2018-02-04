declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'OTHER_DUMMY_OBJECT';
  if l_exists > 0 then
    execute immediate 'drop type other_dummy_object force';
  end if;
end;
/

create or replace type other_dummy_object as object (
  id number,
  "name"  varchar2(30),
  "Value" varchar2(30)
)
/