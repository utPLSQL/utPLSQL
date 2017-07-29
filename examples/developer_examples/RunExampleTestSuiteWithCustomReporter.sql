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
  suite         ut_logical_suite;
  l_reporter    ut_output_reporter_base;
  l_listener    ut_event_listener;
  l_run         ut_run;
begin
  -- Install ut_custom_reporter first from example folder

  suite := ut_logical_suite(a_object_owner=>null, a_object_name => 'ut_exampletest', a_name => null, a_description => 'Test Suite Name',a_path => null);

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

  -- provide a reporter to process results tabbing each hierarcy level by tab_size
  l_reporter := ut_custom_reporter(a_tab_size => 2);
  l_listener := ut_event_listener(ut_reporters(l_reporter));
  l_run := ut_run(ut_suite_items(suite));
  l_run.do_execute(l_listener);
  l_reporter.lines_to_dbms_output(0,0);
end;
/


--FIXME this drop is causing issues when executing script several times within single session
drop type ut_custom_reporter;
drop package ut_exampletest;
drop package ut_exampletest2;
