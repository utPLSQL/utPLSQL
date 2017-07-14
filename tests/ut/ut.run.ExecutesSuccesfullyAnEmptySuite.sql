set termout off
create or replace package empty_suite as
  -- %suite

  procedure not_a_test;
end;
/
create or replace package body empty_suite as
  procedure not_a_test is begin null; end;
end;
/
set termout on
declare
  l_result integer;
begin
  select *
   into l_result
   from table(ut.run('empty_suite',utplsql_test_reporter()));
--Assert
  if l_result = ut_utils.tr_error then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected failure of ''empty_suite'' got: '''||ut_utils.test_result_to_char(l_result)||'''' );
  end if;
end;
/

set termout off
drop package empty_suite;
set termout on
