--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.
--Suite Management packages are when developed will make this easier.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set linesize 1000
set echo off
--install the example unit test packages
@@department$.tps
@@departments$.tps
@@demo_expectations.pck
@@ut_custom_reporter.tps
@@ut_custom_reporter.tpb

begin
  ut_suite_manager.run_cur_schema_suites_static(ut_custom_reporter(a_tab_size => 2));
end;
/

drop type ut_custom_reporter;
drop package demo_expectations;
drop type departments$;
drop type department$;

