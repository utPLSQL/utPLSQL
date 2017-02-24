create or replace package failing_bad_body as
  --%suite
  gv_glob_val number := 0;
  --%beforeall
  procedure before_all;
  --%test
  procedure test1;
  --%test
  procedure test2;
end;
/
set termout off
create or replace package body failing_bad_body as
begin
  null;
end;
/
set termout on

declare
  l_output_data       dbms_output.chararr;
  l_num_lines         integer := 100000;
begin
  --act
  ut.run('failing_bad_body');
  dbms_output.get_lines( l_output_data, l_num_lines);
  for i in 1 .. l_num_lines loop
    if  l_output_data(i) like '%2 tests, 0 failed, 2 errored%' then
      :test_result := ut_utils.tr_success;
    end if;
  end loop;

  if :test_result != ut_utils.tr_success or :test_result is null then
    for i in 1 .. l_num_lines loop
      dbms_output.put_line(l_output_data(i));
    end loop;
    dbms_output.put_line('Failed: Not all tests were marked as failed');
  end if;
end;
/

drop package failing_bad_body
/
