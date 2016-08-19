create or replace package test_pkg1 is

  /*
  This is the correct annotation
  */
  -- %suite(Name of suite on test_pkg1)
  -- %suitepackage(all.globaltests)

  /* 
  Such comments are skipped
  
  test name
  %test1
  %test2(name=123)
    %test3(name2=123,tete=123) 
  %test4(name2=123,tete)
  */
  /*
  This procedure is annotated incorrectly as no correct annotations specified
  Procedure is skipped while suite configuration
  */
  --test name
  --%test1
  --%test2(name=123)
  ----  %test3(name2=123,tete=123) 
  ---- asd %test4(name2=123,tete)
  --  t3 t4
  procedure foo;

  -- %test(Name of test1)
  -- %testsetup(setup_test1)
  -- %testteardown(teardown_test1)
  procedure test1;

  -- %test(Name of test2)
  procedure test2;

  -- %suitesetup
  procedure global_setup;

  procedure setup_test1;

  procedure teardown_test1;

  -- %setup
  procedure def_setup;

  -- %teardown
  procedure def_teardown;

  --%suiteteardown
  procedure global_teardown;

end;
/
create or replace package body test_pkg1 is

  g_val1 number;
  g_val2 number;

  procedure foo is
  begin
    null;
  end;

  procedure test1 is
  begin
    ut_assert.are_equal(a_msg => '1 equals 1 check', a_expected => 1, a_actual => g_val1);
  end;

  procedure test2 is
  begin
    --ut_assert.are_equal(a_msg => 'null equals null check', a_expected => to_number(null), a_actual => g_val1);
    ut_assert.are_equal(a_msg => '2 equals 2 check', a_expected => 2, a_actual => g_val2);
  end;

  procedure global_setup is
  begin
    dbms_output.put_line('setup procedure of test_pkb1');
  end;

  procedure setup_test1 is
  begin
    g_val1 := 1;
  end;

  procedure teardown_test1 is
  begin
    g_val1 := null;
  end;

  procedure def_setup is
  begin
    g_val2 := 2;
  end;

  procedure def_teardown is
  begin
    g_val2 := null;
  end;

  procedure global_teardown is
  begin
    dbms_output.put_line('global teardown procedure of test_pkb1');
  end;
end test_pkg1;
/
