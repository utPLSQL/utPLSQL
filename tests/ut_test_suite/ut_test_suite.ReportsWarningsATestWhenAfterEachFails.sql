create or replace package failing_after_each as
  --%suite
  gv_glob_val number := 0;
  --%test
  procedure test1;
  --%test
  procedure test2;
  --%aftereach
  procedure after_each;
end;
/
create or replace package body failing_after_each as
  procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut.expect(1).to_equal(2); end;
  procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut.expect(1).to_equal(2); end;
  procedure after_each is begin gv_glob_val := 1/0; end;
end;
/

declare
  l_output_data       dbms_output.chararr;
  l_num_lines         integer := 100000;
begin
  --act
  ut.run('failing_after_each');
  dbms_output.get_lines( l_output_data, l_num_lines);
  if failing_after_each.gv_glob_val = 2 then
    for i in 1 .. l_num_lines loop
      if l_output_data(i) like '%2 tests, 0 failed, 2 errored%' then
        :test_result := ut_utils.tr_success;
      end if;
    end loop;
    if :test_result != ut_utils.tr_success or :test_result is null then
      for i in 1 .. l_num_lines loop
        dbms_output.put_line(l_output_data(i));
      end loop;
      dbms_output.put_line('Failed: Not all tests were marked as failed');
    end if;
  else
    dbms_output.put_line('Failed: Not all tests were executed');
  end if;

end;
/

drop package failing_after_each
/
