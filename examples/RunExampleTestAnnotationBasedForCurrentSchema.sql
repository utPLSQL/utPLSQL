--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@test_pkg1.pck
@@test_pkg2.pck

begin
  ut.run(user, ut_documentation_reporter());
end;
/

drop package test_pkg1;
drop package test_pkg2;
