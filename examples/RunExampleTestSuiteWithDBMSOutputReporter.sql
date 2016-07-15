--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
Clear Screen
Set Serveroutput On Size Unlimited
Declare
   testtoexecute ut_types.single_test;
   Suite Ut_Types.Test_Suite;
   Testresults Ut_Types.Test_Suite_Results;
   reporter ut_types.test_suite_reporter;
   
Begin
   Suite.Suite_name := 'Test Suite Name';
   Suite.Tests := ut_Types.Test_List();
   
   Testtoexecute.object_name := 'ut_exampletest';
   Testtoexecute.setup_procedure := 'Setup';
   TestToExecute.teardown_procedure := 'TearDown';
   TestToExecute.test_procedure := 'ut_exampletest';

   Suite.Tests.Extend;
   Suite.Tests(Suite.Tests.Last) := Testtoexecute;

   Testtoexecute.object_name := 'ut_exampletest2';
   Testtoexecute.setup_procedure := 'Setup';
   TestToExecute.teardown_procedure := 'TearDown';
   TestToExecute.test_procedure := 'ut_exampletest';
   
   Suite.Tests.Extend;   
   Suite.Tests(Suite.Tests.LAST) := TestToExecute;
   

   ut_Test_Runner.Execute_Tests(Suite,TestResults);
END;






