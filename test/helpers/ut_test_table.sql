declare
  l_exists integer;
begin
  select count(1) into l_exists from user_tables where table_name = 'UT$TEST_TABLE';
  if l_exists > 0 then
    execute immediate 'drop table ut$test_table';
  end if;
end;
/

create table ut$test_table (val varchar2(1));
