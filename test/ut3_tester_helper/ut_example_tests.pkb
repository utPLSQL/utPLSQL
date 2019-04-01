create or replace package body ut_example_tests
as
  procedure create_synonym is
    pragma autonomous_transaction;
  begin
    execute immediate 'create or replace synonym ut3_tester.ut_example_tests for ut3_tester_helper.ut_example_tests';
  end;
  
  procedure drop_synonym is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop synonym ut3_tester.ut_example_tests';
  end;
  
  procedure set_g_number_0 as
  begin
    g_number := 0;
  end;

  procedure add_1_to_g_number as
  begin
    g_number := g_number + 1;
  end;

  procedure failing_procedure as
  begin
    g_number := 1 / 0;
  end;

  procedure ut_commit_test is
  begin
    commit;
  end;
  
end;
/
