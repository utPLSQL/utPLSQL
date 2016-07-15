--This shows how the interna test engine works to test a single package.
--No tables are used for this and exceptions are handled better.
DECLARE
   TestToExecute ut_Types.Single_Test;
   TestResults ut_Types.test_execution_result;
BEGIN
   --TestToExecute.TypeOfTest := ut_Types.TT_Package;
   testtoexecute.owner_name := USER;
   testtoexecute.object_name := 'UT_EXAMPLETEST';
   testtoexecute.setup_procedure := 'SETUP';
   TestToExecute.TearDown_procedure := 'TEARDOWN';
   testtoexecute.test_procedure := 'UT_EXAMPLETEST';
   ut_Test_Execute.Execute_Test(TestToExecute,TestResults);
   --For now result is an integer but will need a look upto make pretty later.
   dbms_output.put_line('Result: ' || TestResults.result);
   dbms_output.put_line('Assert Results:');
   FOR I in TestResults.Assert_Results.First .. TestResults.Assert_Results.Last
   loop
      dbms_output.put_line(i || ' - result: ' ||  testresults.assert_results(i).result);
      dbms_output.put_line(I || ' - Message: ' ||  TestResults.Assert_Results(I).Message);
   END LOOP;   
END;






