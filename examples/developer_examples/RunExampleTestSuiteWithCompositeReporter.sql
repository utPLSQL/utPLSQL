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
  l_suite        ut_logical_suite;
  l_doc_reporter ut_output_reporter_base := ut_documentation_reporter();
  l_tc_reporter  ut_output_reporter_base := ut_teamcity_reporter();
  l_run          ut_run;
begin
  ut_event_manager.initialize();
  ut_event_manager.add_listener(l_doc_reporter);
  ut_event_manager.add_listener(l_tc_reporter);

  l_suite := ut_suite(user, 'ut_exampletest',a_line_no=>1);
  l_suite.description := 'Test Suite Name';

  l_suite.items.extend;
  l_suite.items(l_suite.items.last) := ut_test(user,'ut_exampletest','ut_exAmpletest',a_line_no=>3);
  l_suite.items.extend;
  l_suite.items(l_suite.items.last) := ut_test(user, 'UT_EXAMPLETEST2','UT_EXAMPLETEST',a_line_no=>6);

  -- provide a reporter to process results
  l_run := ut_run(ut_suite_items(l_suite));
  l_run.do_execute();

  ut_event_manager.trigger_event(ut_event_manager.gc_finalize, l_run);
  l_doc_reporter.lines_to_dbms_output(0,0);
  l_tc_reporter.lines_to_dbms_output(0,0);
end;
/

drop package ut_exampletest;
drop package ut_exampletest2;
