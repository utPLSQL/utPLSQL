create or replace package test_pkg1 is

  /*
  This is the correct annotation
  */
  -- %suite
  -- %displayname(Name of suite on test_pkg1)
  -- %suitepath(all.globaltests)

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
  --%test2
  --%displayname(name=123)
  ----  %test3(name2=123,tete=123)
  ---- asd %test4(name2=123,tete)
  --  t3 t4
  procedure foo;

  -- %test
  -- %displayname(Name of test1)
  -- %beforetest(setup_test1)
  -- %aftertest(teardown_test1)
  procedure test1;

  -- %test
  -- %displayname(Name of test2)
  procedure test2;

  -- %beforeall
  procedure global_setup;

  procedure setup_test1;

  procedure teardown_test1;

  -- %beforeeach
  procedure def_setup;

  -- %aftereach
  procedure def_teardown;

  --%afterall
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
    ut.expect(g_val1,'1 equals 1 check').to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(g_val2,'2 equals 2 check').to_equal(2);
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
