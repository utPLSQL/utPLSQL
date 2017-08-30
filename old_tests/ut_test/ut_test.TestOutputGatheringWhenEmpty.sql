create or replace package ut_output_tests
as
 --%suite
  
 --%test
 procedure ut_passing_test;
 
end;
/

create or replace package body ut_output_tests
as

 procedure ut_passing_test
 as
 begin
   --Generate empty output
   dbms_output.put_line('');
   ut.expect(1,'Test 1 Should Pass').to_equal(1);
 end;
 
end;
/

declare
  l_output_data       dbms_output.chararr;
  l_num_lines         integer := 100000;
  l_output            clob;
begin
  --act
  ut.run('ut_output_tests');

  --assert
  dbms_output.get_lines( l_output_data, l_num_lines);
  dbms_lob.createtemporary(l_output,true);
  for i in 1 .. l_num_lines loop
    dbms_lob.append(l_output,l_output_data(i));
  end loop;
  
  if l_output like '%0 failed, 0 errored, 0 disabled, 0 warning(s)%' then
    :test_result := ut_utils.tr_success;
  end if;

  if :test_result != ut_utils.tr_success or :test_result is null then
    for i in 1 .. l_num_lines loop
      dbms_output.put_line(l_output_data(i));
    end loop;
    dbms_output.put_line('Failed: Wrong output');
  end if;
end;
/

drop package ut_output_tests
/

