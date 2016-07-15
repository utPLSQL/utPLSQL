--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
DECLARE
   TestToExecute ut3Types.SingleTest;
   Suite UT3TYPES.TestSuite;
   TestResults ut3types.TestSuiteResults;
BEGIN
   Suite.SuiteName := 'Test Suite Name';
   Suite.Tests := ut3Types.TestList();
   
   TestToExecute.TypeOfTest := ut3Types.TT_Package;
   TestToExecute.ObjectName := 'ut_exampletest';
   TestToExecute.SetupMethod := 'Setup';
   TestToExecute.TearDownMethod := 'TearDown';
   TestToExecute.TestMethod := 'ut_exampletest';

   Suite.Tests.Extend;
   Suite.Tests(Suite.Tests.LAST) := TestToExecute;
   
   TestToExecute.TypeOfTest := ut3Types.TT_Package;
   TestToExecute.ObjectName := 'ut_exampletest2';
   TestToExecute.SetupMethod := 'Setup';
   TestToExecute.TearDownMethod := 'TearDown';
   TestToExecute.TestMethod := 'ut_exampletest';
   
   Suite.Tests.Extend;   
   Suite.Tests(Suite.Tests.LAST) := TestToExecute;
         
   ut3TestRunner.ExecuteTests(Suite,TestResults);         
END;






