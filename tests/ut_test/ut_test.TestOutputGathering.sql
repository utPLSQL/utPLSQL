create or replace package ut_output_tests
as
 --%suite
  
 --%beforeeach
 procedure beforeeach;
 
 --%aftereach
 procedure aftereach;
 
 --%test
 --%beforetest(beforetest)
 --%aftertest(aftertest)
 procedure ut_passing_test;
 
 procedure beforetest;
 
 procedure aftertest;
 
end;
/

create or replace package body ut_output_tests
as

 procedure beforetest as
 begin
   dbms_output.put_line('<!beforetest!>');
 end;

 procedure aftertest
 as
 begin
   dbms_output.put_line('<!aftertest!>');
 end;
 
 procedure beforeeach as
 begin
   dbms_output.put_line('<!beforeeach!>');
 end;

 procedure aftereach
 as
 begin
   dbms_output.put_line('<!aftereach!>');
 end;

 procedure ut_passing_test
 as
 begin
   dbms_output.put_line('<!thetest!>');
   ut.expect(1,'Test 1 Should Pass').to_equal(1);
 end;

end;
/

declare
  l_output_data       dbms_output.chararr;
  l_num_lines         integer := 100000;
begin
  --act
  ut.run('ut_output_tests');

  --assert
  dbms_output.get_lines( l_output_data, l_num_lines);
  for i in 1 .. l_num_lines loop
    if l_output_data(i) like '%<!beforeeach!>%<!beforetest!>%<!thetest!>%<!aftertest!>%<!aftereach!>%1 tests, 0 failed, 0 errored%' then
      :test_result := ut_utils.tr_success;
    end if;
  end loop;

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

