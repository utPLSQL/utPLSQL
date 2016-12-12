--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@ut_exampletest.pks
show errors
@@ut_exampletest.pkb
show errors
@@ut_exampletest2.pks
show errors
@@ut_exampletest2.pkb
show errors
@@ut_custom_reporter.tps
show errors
@@ut_custom_reporter.tpb
show errors

declare
  suite1        ut_test_suite;
  suite2        ut_test_suite;
  suite_complex ut_test_suite;
  testtoexecute ut_test;
  reporter      ut_reporter;
begin
  suite1 := ut_test_suite(a_suite_name => 'Test Suite 1', a_object_name => null /*,a_items => ut_test_objects_list()*/);

  testtoexecute := ut_test(a_object_name        => 'ut_exampletest'
                          ,a_test_procedure     => 'ut_exAmpletest'
						              ,a_test_name          => 'Example test1'
                          ,a_setup_procedure    => 'Setup'
                          ,a_teardown_procedure => 'tEardown');

  suite1.add_item(testtoexecute);

  suite2        := ut_test_suite(a_suite_name => 'Test Suite 2', a_object_name => null /*,a_items => ut_test_objects_list()*/);
  testtoexecute := ut_test(a_object_name        => 'UT_EXAMPLETEST2'
                          ,a_test_procedure     => 'UT_EXAMPLETEST'
                          ,a_setup_procedure    => 'SETUP'
                          ,a_teardown_procedure => 'TEARDOWN');

  suite2.add_item(testtoexecute);

  suite_complex := ut_test_suite(a_suite_name => 'Complex Test Suite', a_object_name => null, a_items => ut_objects_list(suite1, suite2));

  -- provide a reporter to process results
  reporter := ut_custom_reporter(a_tab_size => 2);
  suite_complex.do_execute(reporter);
end;
/

drop type ut_custom_reporter;
drop package ut_exampletest;
drop package ut_exampletest2;
