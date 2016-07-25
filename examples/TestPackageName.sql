--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off

--Arrange
PROMPT Reports error when unit test package name for a test is null
  declare
    simple_test ut_test;
  begin

  --Act
    simple_test := ut_test(a_object_name => null, a_test_procedure => 'ut_exampletest');

    simple_test.execute();

  --Assert
    if simple_test.execution_result.result = ut_utils.tr_error then
      dbms_output.put_line('  Success');
    else
      dbms_output.put_line('  Failure');
    end if;
  end;
  /

--Arrange
PROMPT Reports error when unit test package name for a test is invalid
  declare
    simple_test ut_test;
  begin

  --Act
    simple_test := ut_test(a_object_name => 'invalid test package name', a_test_procedure => 'ut_exampletest');

    simple_test.execute();

  --Assert
    if simple_test.execution_result.result = ut_utils.tr_error then
      dbms_output.put_line('  Success');
    else
      dbms_output.put_line('  Failure');
    end if;
  end;
  /

--Arrange
PROMPT Reports error when unit test package for a test is in invalid state
  begin
    execute immediate
    'create or replace package invalid_package is
       v_variable non_existing_type;
       procedure ut_exampletest;
     end;';
  exception when others then
    if sqlcode = - 24344 then
      dbms_output.put_line('  Invalid package created');
    else
      raise;
    end if;
  end;
  /

  declare
    simple_test ut_test;
  begin

  --Act
    simple_test := ut_test(a_object_name => 'invalid_package', a_test_procedure => 'ut_exampletest');

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
  drop package invalid_package;
