--Shows how to create a test suite in code and call the test runner.
--No tables are used for this.
--Suite Management packages are when developed will make this easier.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@ut_exampletest.pks
@@ut_exampletest.pkb
@@ut_exampletest2.pks
@@ut_exampletest2.pkb

declare
  suite         ut_suite;
  listener      ut_event_listener := ut_event_listener(ut_reporters());
  test_item     ut_test;
  assert        ut_assert_result;
begin
  suite := ut_suite(a_object_owner=>null, a_object_name => 'ut_exampletest', a_name => null, a_description => 'Test Suite Name',a_path => null);

  suite.add_item(
      ut_test(a_object_name    => 'ut_exampletest'
      ,a_name        => 'ut_exAmpletest'
      ,a_description           => 'Example test1'
      ,a_before_test_proc_name => 'Setup'
      ,a_after_test_proc_name  => 'tEardown')
  );

  suite.add_item(
      ut_test(
          a_object_name           => 'UT_EXAMPLETEST2',
          a_name        => 'UT_EXAMPLETEST',
          a_description           => 'Another example test',
          a_before_test_proc_name => 'SETUP',
          a_after_test_proc_name  => 'TEARDOWN')
  );

  suite.do_execute(listener);

  -- No reporter used in this example so outputing the results manually.
  for test_idx in suite.items.first .. suite.items.last loop
    test_item := treat(suite.items(test_idx) as ut_test);
    dbms_output.put_line('---------------------------------------------------');
    dbms_output.put_line('Test:' || test_item.item.form_name);
    dbms_output.put_line('Result: ' || ut_utils.test_result_to_char(test_item.result));
    dbms_output.put_line('Assert Results:');
    for i in test_item.results.first .. test_item.results.last loop
			assert := test_item.results(i);
      dbms_output.put_line(i || ' - result: ' || ut_utils.test_result_to_char(assert.result));
      dbms_output.put_line(i || ' - Message: ' || assert.message);
    end loop;
  end loop;
  dbms_output.put_line('---------------------------------------------------');
end;
/

drop package ut_exampletest;
drop package ut_exampletest2;
