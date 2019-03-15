declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'T_TAB_VARCHAR';
  if l_exists > 0 then
    execute immediate 'drop type t_tab_varchar force';
  end if;
end;
/

create or replace type t_tab_varchar is table of varchar2(1)
/