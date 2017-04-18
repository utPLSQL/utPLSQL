set termout off
create table test_dependency_table (id integer);
create or replace package test_dependencies as
  -- %suite

  -- %test
  procedure dependant;
end;
/
create or replace package body test_dependencies as
  gc_dependant_variable test_dependency_table.id%type;
  procedure dependant is begin null; end;
end;
/
alter table test_dependency_table modify id number;
set termout on

declare
  l_result integer;
begin
  select *
   into l_result
   from table(ut.run('test_dependencies',utplsql_test_reporter()));
  :test_result := l_result;
end;
/

set termout off
drop table test_dependency_table;
drop package test_dependencies;
set termout on
