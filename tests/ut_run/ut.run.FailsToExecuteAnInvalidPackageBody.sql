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
drop table test_dependency_table;
set termout on

declare
  l_result integer;
begin
  select *
   into l_result
   from table(ut.run('test_dependencies',utplsql_test_reporter()));
--Assert
  if l_result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected failure of ''test_dependencies'' got: '''||ut_utils.test_result_to_char(l_result)||'''' );
  end if;
end;
/

set termout off
drop package test_dependencies;
set termout on
