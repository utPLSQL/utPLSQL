create or replace package ut_output_test_rollback
as
 --%suite

 --%test
 procedure tt;

end;
/

create or replace package body ut_output_test_rollback
as

 procedure tt is
  begin
    commit;
  end;

end;
/

declare
  l_lines    ut_varchar2_list;
  l_results  clob;
begin
  --act
  select * bulk collect into l_lines from table(ut.run('ut_output_test_rollback'));

  l_results := ut_utils.table_to_clob(l_lines);

  --assert
  if l_results like '%Warnings:%Unable to perform automatic rollback after test suite: ut_output_test_rollback%
An implicit or explicit commit/rollback occurred.%
Use the %rollback(manual) annotation or remove commits/rollback/ddl statements that are causing the issue.%0 disabled, 1 warning(s)%' then
    :test_result := ut_utils.tr_success;
  else
    for i in 1 .. l_lines.count loop
      dbms_output.put_line(l_lines(i));
    end loop;
    dbms_output.put_line('Failed: Wrong output');
  end if;
end;
/

drop package ut_output_test_rollback
/

