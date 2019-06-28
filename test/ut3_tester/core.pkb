create or replace package body core is

  procedure global_setup is
  begin
    ut3_tester_helper.coverage_helper.set_develop_mode();
    --improve performance of test execution by disabling all compiler optimizations
    ut3_tester_helper.main_helper.execute_autonomous('ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=0');
  end;

end;
/
