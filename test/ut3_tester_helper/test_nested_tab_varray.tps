declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_NESTED_TAB_VARRAY';
  if l_exists > 0 then
    execute immediate 'drop type test_nested_tab_varray force';
  end if;
end;
/

create or replace type test_nested_tab_varray as object (
  n_varray t_varray
)
/
