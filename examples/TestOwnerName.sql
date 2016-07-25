--This shows how the interna test engine works to test a single package.
--No tables are used for this and exceptions are handled better.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off

--Arrange
@@ut_exampletest.pks
@@ut_exampletest.pkb

PROMPT Does not report error when test owner name for a test is null
declare
  simple_test ut_test;
begin

--Act
  simple_test := ut_test(a_object_name        => 'ut_exampletest'
                        ,a_test_procedure     => 'ut_exampletest'
                        ,a_owner_name         => null);

  simple_test.execute();

--Assert
  if simple_test.execution_result.result != ut_utils.tr_error then
    dbms_output.put_line('  Success');
  else
    dbms_output.put_line('  Failure');
  end if;
end;
/

PROMPT Reports error when test owner name for a test is invalid
declare
  simple_test ut_test;
begin

--Act
  simple_test := ut_test(a_object_name        => 'ut_exampletest'
                        ,a_test_procedure     => 'ut_exampletest'
                        ,a_owner_name         => 'invalid owner name');

  simple_test.execute();

--Assert
  if simple_test.execution_result.result = ut_utils.tr_error then
    dbms_output.put_line('  Success');
  else
    dbms_output.put_line('  Failure');
  end if;
end;
/

--Cleanup
drop package ut_exampletest;
