create or replace package test_package_2 is

  --%suite
  --%suitepackage(tests.test_package_1)

  gv_glob_val varchar2(1);

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

end test_package_2;
/
create or replace package body test_package_2 is

  gv_var_1 varchar2(1);

  gv_var_1_temp varchar2(1);

  procedure global_setup is
  begin
    gv_var_1    := 'a';
    gv_glob_val := 'z';
  end;

  procedure global_teardown is
  begin
    gv_var_1    := 'n';
    gv_glob_val := 'n';
  end;

  procedure test1 is
  begin
    ut.expect(gv_var_1).to_equal('a');
  end;

  procedure test2 is
  begin
    ut.expect(gv_var_1).to_equal('b');
  end;

  procedure test2_setup is
  begin
    gv_var_1_temp := gv_var_1;
    gv_var_1      := 'b';
  end;

  procedure test2_teardown is
  begin
    gv_var_1      := gv_var_1_temp;
    gv_var_1_temp := null;
  end;

end test_package_2;
/
