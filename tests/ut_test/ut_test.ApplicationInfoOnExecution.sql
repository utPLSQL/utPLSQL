create or replace package ut_output_tests
as
 --%suite
 
  gv_before_all_client_info varchar2(200);
  gv_before_each_client_info varchar2(200);
  gv_before_test_client_info varchar2(200);
  gv_after_test_client_info varchar2(200);
  gv_after_each_client_info varchar2(200);
  gv_after_all_client_info varchar2(200);
  
 --%test
 --%beforetest(before_test)
 --%aftertest(after_test)
 procedure the_test;
 
 --%beforeall
 procedure beforeall;
 
 --%beforeeach
 procedure beforeeach;
 
 procedure before_test;
 procedure after_test;
 
 --%aftereach
 procedure after_each;
 
 --%afterall
 procedure afterall;
 
end;
/

create or replace package body ut_output_tests
as

 procedure the_test
 as
   l_module_name varchar2(4000);
   l_action_name varchar2(4000);
   l_client_info varchar2(4000);
 begin
   --Generate empty output
   dbms_output.put_line('');
   ut.expect(1,'Test 1 Should Pass').to_equal(1);
   dbms_application_info.read_module(module_name => l_module_name, action_name => l_action_name);
   dbms_application_info.read_client_info(l_client_info);
   ut.expect(l_module_name).to_equal('utPLSQL');
   ut.expect(l_action_name).to_be_like('Suite: ut_output_tests');
   ut.expect(l_client_info).to_be_like('Test: the_test');
 end;
 
 procedure beforeall is 
 begin 
   dbms_application_info.read_client_info(gv_before_all_client_info);
 end;
 
 procedure beforeeach is 
 begin 
   dbms_application_info.read_client_info(gv_before_each_client_info);
 end;
 
 procedure before_test is 
 begin 
   dbms_application_info.read_client_info(gv_before_test_client_info);
 end;
 procedure after_test is 
 begin 
   dbms_application_info.read_client_info(gv_after_test_client_info);
 end;
 
 procedure after_each is 
 begin 
   dbms_application_info.read_client_info(gv_after_each_client_info);
 end;
 
 procedure afterall is 
 begin 
   dbms_application_info.read_client_info(gv_after_all_client_info);
 end;
 
end;
/

declare
  l_output_data       dbms_output.chararr;
  l_num_lines         integer := 100000;
  l_output            clob;
  l_result            boolean := true;
  l_client_info varchar2(4000);
begin
  --act
  ut.run('ut_output_tests');

  --assert
  dbms_output.get_lines( l_output_data, l_num_lines);
  dbms_lob.createtemporary(l_output,true);
  for i in 1 .. l_num_lines loop
    dbms_lob.append(l_output,l_output_data(i));
  end loop;
  
  execute immediate 'begin :i := ut_output_tests.gv_before_all_client_info; end;' using out l_client_info;
  if not nvl(l_client_info = 'Suite: ut_output_tests (before_all)', false) then
    dbms_output.put_line('Wrong before all text: '||l_client_info);
    l_result := false;
  end if;
  execute immediate 'begin :i := ut_output_tests.gv_before_each_client_info; end;' using out  l_client_info;
  if not nvl(l_client_info = 'Test: the_test (before_each)', false) then
    dbms_output.put_line('Wrong before each text: '||l_client_info);
    l_result := false;
  end if;
  execute immediate 'begin :i := ut_output_tests.gv_before_test_client_info; end;' using out  l_client_info;
  if not nvl(l_client_info = 'Test: the_test (before_test)', false) then
    dbms_output.put_line('Wrong before test text: '||l_client_info);
    l_result := false;
  end if;
  execute immediate 'begin :i := ut_output_tests.gv_after_test_client_info; end;' using out  l_client_info;
  if not nvl(l_client_info = 'Test: the_test (after_test)', false) then
    dbms_output.put_line('Wrong after test text: '||l_client_info);
    l_result := false;
  end if;
  execute immediate 'begin :i := ut_output_tests.gv_after_each_client_info; end;' using out  l_client_info;
  if not nvl(l_client_info = 'Test: the_test (after_each)', false) then
    dbms_output.put_line('Wrong after each text: '||l_client_info);
    l_result := false;
  end if;
  execute immediate 'begin :i := ut_output_tests.gv_after_all_client_info; end;' using out  l_client_info;
  if not nvl(l_client_info = 'Suite: ut_output_tests (after_all)', false) then
    dbms_output.put_line('Wrong after all text: '||l_client_info);
    l_result := false;
  end if;
  
  if not nvl(l_output like '%0 failed, 0 errored, 0 disabled, 0 warning(s)%',false) then
    l_result := false;
    for i in 1 .. l_num_lines loop
      dbms_output.put_line(l_output_data(i));
    end loop;
    dbms_output.put_line('Failed: Wrong output');
  end if;
  if l_result then
    :test_result := ut_utils.tr_success;
  end if;
end;
/

drop package ut_output_tests
/

