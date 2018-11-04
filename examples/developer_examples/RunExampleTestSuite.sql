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
  l_suite         ut_logical_suite;
  l_test          ut_test;
  l_expectation   ut_expectation_result;
begin
  l_suite := ut_suite(user, 'ut_exampletest',a_line_no=>1);
  l_suite.description := 'Test Suite Name';
  l_test := ut_test(user, 'ut_exampletest','ut_exAmpletest',a_line_no=>3);
  l_test.description := 'Example test1';
  l_test.before_test_list := ut_executables(ut_executable(user, 'ut_exampletest','Setup',ut_utils.gc_before_test));
  l_test.after_test_list  := ut_executables(ut_executable(user, 'ut_exampletest','tEardown',ut_utils.gc_after_test));
  l_suite.add_item(l_test);

  l_test := ut_test(user, 'UT_EXAMPLETEST2','ut_exAmpletest',a_line_no=>6);
  l_test.description := 'Another example test';
  l_test.before_test_list := ut_executables(ut_executable(user, 'UT_EXAMPLETEST2','SETUP',ut_utils.gc_before_test));
  l_test.after_test_list  := ut_executables(ut_executable(user, 'UT_EXAMPLETEST2','TEARDOWN',ut_utils.gc_after_test));
  l_suite.add_item(l_test);

  l_suite.do_execute();

  -- No reporter used in this example so outputing the results manually.
  for test_idx in l_suite.items.first .. l_suite.items.last loop
    l_test := treat(l_suite.items(test_idx) as ut_test);
    dbms_output.put_line('---------------------------------------------------');
    dbms_output.put_line('Test:' || l_test.item.form_name);
    dbms_output.put_line('Result: ' || ut_utils.test_result_to_char(l_test.result));
    dbms_output.put_line('expectation Results:');
    for i in 1 .. l_test.failed_expectations.count loop
      l_expectation := l_test.failed_expectations(i);
      dbms_output.put_line(i || ' - result: ' || ut_utils.test_result_to_char(l_expectation.result));
      dbms_output.put_line(i || ' - Message: ' || l_expectation.message);
    end loop;
  end loop;
  dbms_output.put_line('---------------------------------------------------');
end;
/

drop package ut_exampletest;
drop package ut_exampletest2;
