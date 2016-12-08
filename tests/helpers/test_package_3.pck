create or replace package test_package_3 is

  --%suite
  --%suitepackage(tests2)

  gv_glob_val number;

  --%setup
  procedure global_setup;

  --%teardown
  procedure global_teardown;

  --%test
  procedure test1;

  --%test
  --%testsetup(test2_setup)
  --%testteardown(test2_teardown)
  procedure test2;

  procedure test2_setup;

  procedure test2_teardown;

end test_package_3;
/
create or replace package body test_package_3 is

  gv_var_1 number;

  gv_var_1_temp number;

  procedure global_setup is
  begin
    gv_var_1    := 1;
    gv_glob_val := 1;
  end;

  procedure global_teardown is
  begin
    gv_var_1    := 0;
    gv_glob_val := 0;
  end;

  procedure test1 is
  begin
    ut.expect(gv_var_1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(gv_var_1).to_equal(2);
  end;

  procedure test2_setup is
  begin
    gv_var_1_temp := gv_var_1;
    gv_var_1      := 2;
  end;

  procedure test2_teardown is
  begin
    gv_var_1      := gv_var_1_temp;
    gv_var_1_temp := null;
  end;

end test_package_3;
/
