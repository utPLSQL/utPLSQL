create or replace package body ut_dbms_output_reporter
as
  c_dashed_line constant varchar2(80) := 
'--------------------------------------------------------------------------------';

  procedure begin_suite (a_suite in ut_types.test_suite)
  as
  begin
    dbms_output.put_line(c_dashed_line);
    dbms_output.put_line('suite "' || nvl(a_suite.suite_name,'') || '" started.');
  end;
  
  procedure end_suite (a_suite in ut_types.test_suite, a_results in ut_types.test_suite_results)
  as
  begin
    --todo: report total suite result here with pretty message
    dbms_output.put_line(c_dashed_line);   
    dbms_output.put_line('suite "' || nvl(a_suite.suite_name,'') || '" ended.');
    dbms_output.put_line(c_dashed_line);      
  end;  
  
  procedure begin_test(a_test in ut_types.single_test,a_in_suite in boolean)
  as
  begin
    null;
  end;  
  
  procedure end_test(a_test in ut_types.single_test, a_result ut_types.test_execution_result,a_in_suite in boolean)
  as
  begin
    dbms_output.put_line(c_dashed_line);
    dbms_output.put_line('test  '|| nvl(a_result.test.owner_name ,'') || nvl(a_result.test.object_name ,'') || '.' || nvl(a_result.test.test_procedure ,''));
    dbms_output.put_line('result: ' || ut_types.test_result_to_char(a_result.result));
    dbms_output.put_line('asserts');
   for i in a_result.assert_results.first .. a_result.assert_results.last
   loop
      dbms_output.put('assert ' || i || ' ' ||  ut_types.test_result_to_char(a_result.assert_results(i).result));
      dbms_output.put_line(' message: ' ||  a_result.assert_results(i).message);
   end loop;   
  end;  

end;