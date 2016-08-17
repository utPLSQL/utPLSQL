CREATE OR REPLACE PACKAGE test_tt AS

  -- %suite(Name of suite)
	-- %suitepackage(all.globaltests)

  /* 
  test name
  %test1
  %test2(name=123)
    %test3(name2=123,tete=123) 
  %test4(name2=123,tete)
  */
  --test name
  --%test1
  --%test2(name=123)
  ----  %test3(name2=123,tete=123) 
  ---- asd %test4(name2=123,tete)
  --  t3 t4
  PROCEDURE foo;

  -- %test(Name of test1)
  -- %testsetup(setup_test1)
  -- %testteardown(teardown_test1)
  PROCEDURE test1;

  -- %test(Name of test2)
  PROCEDURE test2;

  -- %suitesetup
  PROCEDURE setup;

  PROCEDURE setup_test1;

  PROCEDURE teardown_test1;
  
  -- %setup
  procedure def_setup;
  
  -- %teardown
  procedure def_teardown;

  --%suiteteardown
  PROCEDURE global_teardown;

END;
/
