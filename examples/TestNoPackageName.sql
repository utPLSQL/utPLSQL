--Reports error when package name is null.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off

declare
  simple_test ut_test;
begin

  simple_test := ut_test(a_object_name        => NULL
                        ,a_test_procedure     => 'ut_exampletest'
                        ,a_test_name          => 'Simple test1'
                        ,a_owner_name         => user
                        ,a_setup_procedure    => 'setup'
                        ,a_teardown_procedure => 'teardown');

  simple_test.execute(ut_dbms_output_suite_reporter);
end;
/
