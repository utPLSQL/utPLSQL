--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.
--Suite Management packages are when developed will make this easier.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set linesize 10000
set echo off
--install the example unit test packages
@@department.tps
show errors
@@departments.tps
show errors
@@demo_expectations.pck
show errors
@@ut_custom_reporter.tps
show errors
@@ut_custom_reporter.tpb
show errors

begin
  ut.run(user, ut_documentation_reporter());
end;
/

drop type ut_custom_reporter;
drop package demo_expectations;
drop type departments$;
drop type department$;

