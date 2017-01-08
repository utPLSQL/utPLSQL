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
@@ut_custom_reporter.tps
@@ut_custom_reporter.tpb

declare
  suite1        ut_suite;
  suite2        ut_suite;
  suite_complex ut_suite;
  listener      ut_event_listener;
begin
  suite1 := ut_suite(a_object_owner=>null, a_object_name => null, a_name => null, a_description => 'Test Suite 1');

  suite1.add_item(
      ut_test(a_object_name    => 'ut_exampletest'
      ,a_name                  => 'ut_exAmpletest'
      ,a_description           => 'Example test1'
      ,a_before_test_proc_name => 'Setup'
      ,a_after_test_proc_name  => 'tEardown')
  );

  suite2        := ut_suite(a_object_owner=>null, a_object_name => null, a_name => null, a_description => 'Test Suite 2');

  suite2.add_item(
      ut_test(
      a_object_name           => 'UT_EXAMPLETEST2',
      a_name                  => 'UT_EXAMPLETEST',
      a_description           => 'Another example test',
      a_before_test_proc_name => 'SETUP',
      a_after_test_proc_name  => 'TEARDOWN')
  );

  suite_complex := ut_suite( a_object_owner=>null, a_object_name => null, a_name => null, a_description => 'Complex Test Suite');
  suite_complex.items := ut_suite_items(suite1, suite2);

  -- provide a reporter to process results
  listener := ut_event_listener(ut_reporters(ut_custom_reporter(a_tab_size => 2)));
  suite_complex.do_execute(listener);
end;
/

drop type ut_custom_reporter;
drop package ut_exampletest;
drop package ut_exampletest2;
