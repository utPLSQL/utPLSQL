PL/SQL Developer Test script 3.0
45
--Shows how to create a test suite in code and call the test runner.
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
--Clear Screen
--Set Serveroutput On Size Unlimited

declare
  testtoexecute ut_single_test;
  suite         ut_test_suite;
--  testresults   ut_suite_results;
	test_item ut_single_test;
begin
  suite := ut_test_suite(a_suite_name => 'Test Suite Name' /*,a_tests => ut_Test_List()*/);

  testtoexecute := ut_single_test(a_object_name        => 'ut_exampletest'
                                 ,a_test_procedure     => 'ut_exAmpletest'
                                 ,a_setup_procedure    => 'Setup'
                                 ,a_teardown_procedure => 'tEardown');

  suite.add_test(testtoexecute);

  testtoexecute := ut_single_test(a_object_name        => 'UT_EXAMPLETEST2'
                                 ,a_test_procedure     => 'UT_EXAMPLETEST'
                                 ,a_setup_procedure    => 'SETUP'
                                 ,a_teardown_procedure => 'TEARDOWN');

  suite.add_test(testtoexecute);
	suite.execute;

  -- No reporter used in this example so outputing the results manually.
  for test_idx in suite.items.first .. suite.items.last loop
		test_item := treat(suite.items(test_idx) as ut_single_test);
    dbms_output.put_line('---------------------------------------------------');
    dbms_output.put_line('Test:' || test_item.call_params.object_name || '.' || test_item.call_params.test_procedure);
    dbms_output.put_line('Result: ' || test_item.execution_result.result_to_char);
    dbms_output.put_line('Assert Results:');
    for i in test_item.assert_results.first .. test_item.assert_results.last loop
      dbms_output.put_line(i || ' - result: ' ||
                           test_item.assert_results(i).result_to_char);
      dbms_output.put_line(i || ' - Message: ' || test_item.assert_results(i).message);
    end loop;
  end loop;
  dbms_output.put_line('---------------------------------------------------');
end;

0
4
call_params.owner

schema
part1
