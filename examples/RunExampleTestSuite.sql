--Shows how to create a test suite in code and call the test runner.
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
DECLARE
   testtoexecute ut_types.singletest;
   Suite UT_TYPES.TestSuite;
   TestResults ut_types.TestSuiteResults;
BEGIN
   Suite.SuiteName := 'Test Suite Name';
   Suite.Tests := ut_Types.TestList();
   
   TestToExecute.TypeOfTest := ut_Types.TT_Package;
   TestToExecute.ObjectName := 'ut_exampletest';
   TestToExecute.SetupMethod := 'Setup';
   TestToExecute.TearDownMethod := 'TearDown';
   TestToExecute.TestMethod := 'ut_exampletest';

   Suite.Tests.Extend;
   Suite.Tests(Suite.Tests.LAST) := TestToExecute;
   /
   TestToExecute.TypeOfTest := ut3Types.TT_Package;
   TestToExecute.ObjectName := 'ut_exampletest2';
   TestToExecute.SetupMethod := 'Setup';
   TestToExecute.TearDownMethod := 'TearDown';
   TestToExecute.TestMethod := 'ut_exampletest';
   
   Suite.Tests.Extend;   
   Suite.Tests(Suite.Tests.LAST) := TestToExecute;
         
   ut3TestRunner.ExecuteTests(Suite,null,TestResults);
      
   -- No reporter used in this example so outputing the results manually.
   FOR test_idx in TestResults.first .. TestResults.last
   LOOP
       dbms_output.put_line('---------------------------------------------------');
       dbms_output.put_line('Test:' || TestResults(test_idx).Test.ObjectName || '.' || TestResults(test_idx).Test.TestMethod ); 
       dbms_output.put_line('Result: ' || TestResults(test_idx).result);
       dbms_output.put_line('Assert Results:');
       FOR I in TestResults(test_idx).AssertResults.First .. TestResults(test_idx).AssertResults.Last
       LOOP
          dbms_output.put_line(I || ' - result: ' ||  TestResults(test_idx).AssertResults(I).AssertResult);
          dbms_output.put_line(I || ' - Message: ' ||  TestResults(test_idx).AssertResults(I).Message);
       END LOOP;   
   END LOOP;
   dbms_output.put_line('---------------------------------------------------');
END;






