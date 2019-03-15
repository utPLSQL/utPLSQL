declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'T_VARRAY';
  if l_exists > 0 then
    execute immediate 'drop type t_varray force';
  end if;
end;
/


create or replace type t_varray is varray(1) of number
/