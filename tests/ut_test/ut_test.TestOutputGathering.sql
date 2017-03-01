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
 
 --%beforeall
 procedure beforeall;
 --%afterall 
 procedure afterall;
 
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
 
 procedure beforeall is
 begin
   dbms_output.put_line('<!beforeall!>');
 end;

 procedure afterall is
 begin
   dbms_output.put_line('<!afterall!>');
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
  
  if l_output like '%<!beforeall!>%<!beforeeach!>%<!beforetest!>%<!thetest!>%<!aftertest!>%<!aftereach!>%<!afterall!>%1 tests, 0 failed, 0 errored%' then
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

