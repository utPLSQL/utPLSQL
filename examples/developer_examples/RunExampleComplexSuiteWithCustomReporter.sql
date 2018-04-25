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
  l_parent_suite ut_logical_suite;
  l_suite        ut_suite;
  l_test         ut_test;
  l_reporter     ut_output_reporter_base;
  l_run          ut_run;
begin
  ut_event_manager.initialize();
  l_parent_suite := ut_logical_suite( a_object_owner=>null, a_object_name => null, a_name => 'complex_test_suite', a_path => null);

  l_suite := ut_suite(user, 'ut_exampletest');
  l_test := ut_test(user, 'ut_exampletest','ut_exAmpletest');
  l_test.description      := 'Example test1';
  l_test.before_test_list := ut_executables(ut_executable(user, 'ut_exampletest','Setup',ut_utils.gc_before_test));
  l_test.after_test_list  := ut_executables(ut_executable(user, 'ut_exampletest','tEardown',ut_utils.gc_after_test));

  l_suite.add_item(l_test);
  l_parent_suite.add_item(l_suite);


  l_suite := ut_suite(user, 'ut_exampletest2');
  l_test := ut_test(user, 'UT_EXAMPLETEST2','UT_EXAMPLETEST');
  l_test.before_test_list := ut_executables(ut_executable(user, 'UT_EXAMPLETEST2','SETUP',ut_utils.gc_before_test));
  l_test.after_test_list  := ut_executables(ut_executable(user, 'UT_EXAMPLETEST2','TEARDOWN',ut_utils.gc_after_test));

  l_suite.add_item(l_test);
  l_parent_suite.add_item(l_suite);

  -- provide a reporter to process results
  l_reporter := ut_custom_reporter(a_tab_size => 2);
  ut_event_manager.add_listener(l_reporter);
  l_run := ut_run(ut_suite_items(l_parent_suite));
  l_run.do_execute();
  ut_event_manager.trigger_event(ut_utils.gc_finalize, l_run);
  l_reporter.lines_to_dbms_output();
end;
/

drop type ut_custom_reporter;
drop package ut_exampletest;
drop package ut_exampletest2;
exec dbms_session.reset_package;
