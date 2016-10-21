--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
--Clear Screen
--http://stackoverflow.com/questions/2584492/how-to-prevent-dbms-output-put-line-from-trimming-leading-whitespace
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@ut_exampletest.pks
@@ut_exampletest.pkb
@@ut_exampletest2.pks
@@ut_exampletest2.pkb
@@ut_custom_reporter.tps
@@ut_custom_reporter.tpb

declare
  suite         ut_test_suite;
  testtoexecute ut_test;
begin
  -- Install ut_custom_reporter first from example folder	

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

  -- provide a reporter to process results tabbing each hierarcy level by tab_size
  suite.do_execute(ut_custom_reporter(a_tab_size => 2));
end;
/


--FIXME this drop is causing issues when executing script several times within single session
drop type ut_custom_reporter;
drop package ut_exampletest;
drop package ut_exampletest2;
