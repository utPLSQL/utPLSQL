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
  suite          ut_logical_suite;
  l_doc_reporter ut_output_reporter_base := ut_documentation_reporter();
  l_tc_reporter  ut_output_reporter_base := ut_teamcity_reporter();
  l_listener    ut_event_listener := ut_event_listener(ut_reporters(l_doc_reporter, l_tc_reporter));
  l_run          ut_run;
begin
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

  -- provide a reporter to process results
  l_run := ut_run(ut_suite_items(suite));
  l_run.do_execute(l_listener);
  l_doc_reporter.lines_to_dbms_output(0,0);
  l_tc_reporter.lines_to_dbms_output(0,0);
end;
/

drop package ut_exampletest;
drop package ut_exampletest2;
