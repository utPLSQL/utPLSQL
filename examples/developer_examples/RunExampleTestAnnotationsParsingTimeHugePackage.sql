--Shows that even a very large package specification can be parsed quite quickly
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@tst_pkg_huge.pks

declare
  l_suites ut_suite_items;
begin
  l_suites := ut_suite_manager.configure_execution_by_path(ut_varchar2_list(USER||'.TST_PKG_HUGE'));
end;
/

drop package tst_pkg_huge;
