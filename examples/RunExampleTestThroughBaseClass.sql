--This shows how the interna test engine works to test a single package.
--No tables are used for this and exceptions are handled better.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@ut_exampletest.pks
@@ut_exampletest.pkb

declare
  simple_test ut_test;
  listener      ut_execution_listener;
begin

  simple_test := ut_test(
      a_object_name    => 'ut_exampletest'
      , a_name        => 'ut_exampletest'
      , a_description           => 'Example test1'
      , a_before_test_proc_name => 'setup'
      , a_after_test_proc_name  => 'teardown');

  listener := ut_execution_listener(ut_reporters(ut_documentation_reporter()));
  simple_test.do_execute(listener);
end;
/

drop package ut_exampletest;
