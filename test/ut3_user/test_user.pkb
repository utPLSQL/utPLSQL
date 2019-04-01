create or replace package body test_user is

   procedure global_setup is
  begin
    ut3.ut_coverage.set_develop_mode(true);
    --improve performance of test execution by disabling all compiler optimizations
    ut3_tester_helper.main_helper.execute_autonomous('ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=0');
    --dbms_output.enable(null);
  end;

end;
/
