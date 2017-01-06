--Shows that even a very large package specification can be parsed quite quickly
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@tst_pkg_huge.pks

declare
  l_suite ut_suite;
begin
  l_suite := ut_suite_manager.config_package(a_owner_name => USER,a_object_name => 'TST_PKG_HUGE');
end;
/

drop package tst_pkg_huge;
