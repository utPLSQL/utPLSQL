--Shows how to create a test suite in code and call the test runner.
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
Clear Screen
Set Serveroutput On Size Unlimited

declare
  suite         ut_test_suite;
  testtoexecute ut_test;
  test_item     ut_test;
begin
  suite := ut_test_suite(a_suite_name => 'Test Suite Name' /*,a_items => ut_test_objects_list()*/);

  testtoexecute := ut_test(a_object_name        => 'ut_exampletest'
                          ,a_test_procedure     => 'ut_exAmpletest'
                          ,a_setup_procedure    => 'Setup'
                          ,a_teardown_procedure => 'tEardown');

  suite.add_item(testtoexecute);

  testtoexecute := ut_test(a_object_name        => 'UT_EXAMPLETEST2'
                          ,a_test_procedure     => 'UT_EXAMPLETEST'
                          ,a_setup_procedure    => 'SETUP'
                          ,a_teardown_procedure => 'TEARDOWN');

  suite.add_item(testtoexecute);
  suite.execute;

  -- No reporter used in this example so outputing the results manually.
  for test_idx in suite.items.first .. suite.items.last loop
    test_item := treat(suite.items(test_idx) as ut_test);
    dbms_output.put_line('---------------------------------------------------');
    dbms_output.put_line('Test:' || test_item.call_params.object_name || '.' || test_item.call_params.test_procedure);
    dbms_output.put_line('Result: ' || test_item.execution_result.result_to_char);
    dbms_output.put_line('Assert Results:');
    for i in test_item.assert_results.first .. test_item.assert_results.last loop
      dbms_output.put_line(i || ' - result: ' || test_item.assert_results(i).result_to_char);
      dbms_output.put_line(i || ' - Message: ' || test_item.assert_results(i).message);
    end loop;
  end loop;
  dbms_output.put_line('---------------------------------------------------');
end;
/
