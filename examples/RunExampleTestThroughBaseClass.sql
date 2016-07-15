--This shows how the interna test engine works to test a single package.
--No tables are used for this and exceptions are handled better.
Clear Screen
Set Serveroutput On Size Unlimited
declare
   testtoexecute ut_types.single_test;
   testresults   ut_types.test_execution_result;
begin
   --testtoexecute.typeoftest := ut_types.tt_package;
   testtoexecute.owner_name := user;
   testtoexecute.object_name        := 'ut_exampletest';
   testtoexecute.setup_procedure    := 'setup';
   testtoexecute.teardown_procedure := 'teardown';
   testtoexecute.test_procedure     := 'ut_exampletest';
   ut_test_execute.execute_test(testtoexecute,testresults);

   --for now result is an integer but will need a look upto make pretty later.
   dbms_output.put_line('result: ' || ut_types.test_result_to_char(testresults.result) );
   dbms_output.put_line('assert results:');
   for i in testresults.assert_results.first .. testresults.assert_results.last
   Loop
      dbms_output.put_line(i || ' - result: ' ||  ut_types.test_result_to_char(testresults.assert_results(i).result) );
      dbms_output.put_line(i || ' - message: ' ||  testresults.assert_results(i).message);
   end loop;   
end;
