--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.
--Suite Management packages are when developed will make this easier.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set linesize 10000
set echo off
--install the example unit test packages
@@department.tps
@@departments.tps
@@demo_expectations.pck

begin
  ut_coverage.coverage_start_develop();
  ut.run();
  ut_coverage.coverage_stop_develop();
end;
/

drop package demo_expectations;
drop type departments$;
drop type department$;

