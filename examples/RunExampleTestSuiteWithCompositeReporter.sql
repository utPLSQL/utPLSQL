--Shows how to create a test suite with the default reporter which is dbms_output
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

PROMPT Runs test report using composite reporter
declare
  suite         ut_test_suite;
  testtoexecute ut_test;
  reporter      ut_reporter;
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

  -- provide a reporter to process results
  reporter := ut_composite_reporter(ut_reporters_list(ut_dbms_output_suite_reporter, ut_dbms_output_suite_reporter));
  suite.do_execute(reporter);
end;
/

drop package ut_exampletest;
drop package ut_exampletest2;
