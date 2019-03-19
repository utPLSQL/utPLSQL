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
  l_suite       ut_logical_suite;
  l_test        ut_test;
  l_reporter    ut_output_reporter_base;
  l_run         ut_run;
begin
  ut_event_manager.initialize();
  -- Install ut_custom_reporter first from example folder

  l_suite := ut_suite(user, 'ut_exampletest',a_line_no=>1);

  l_test := ut_test(user, 'ut_exampletest','ut_exAmpletest',a_line_no=>3);
  l_test.description := 'Example test1';
  l_test.before_test_list := ut_executables(ut_executable(user, 'ut_exampletest','Setup',ut_utils.gc_before_test));
  l_test.after_test_list  := ut_executables(ut_executable(user, 'ut_exampletest','tEardown',ut_utils.gc_after_test));
  l_suite.items.extend;
  l_suite.items(l_suite.items.last) := l_test;

  l_test := ut_test(user, 'UT_EXAMPLETEST2','ut_exAmpletest',a_line_no=>6);
  l_test.description := 'Another example test';
  l_test.before_test_list := ut_executables(ut_executable(user, 'ut_exampletest','SETUP',ut_utils.gc_before_test));
  l_test.after_test_list  := ut_executables(ut_executable(user, 'ut_exampletest','TEARDOWN',ut_utils.gc_after_test));
  l_suite.items.extend;
  l_suite.items(l_suite.items.last) := l_test;

  -- provide a reporter to process results tabbing each hierarcy level by tab_size
  l_reporter := ut_custom_reporter(a_tab_size => 2);
  ut_event_manager.add_listener(l_reporter);
  l_run := ut_run(ut_suite_items(l_suite));
  l_run.do_execute();
  ut_event_manager.trigger_event(ut_event_manager.gc_finalize, l_run);
  l_reporter.lines_to_dbms_output(0,0);
end;
/


--FIXME this drop is causing issues when executing script several times within single session
drop type ut_custom_reporter;
drop package ut_exampletest;
drop package ut_exampletest2;
exec dbms_session.reset_package;
