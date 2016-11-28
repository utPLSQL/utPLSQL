--Shows how to create a test suite with the default reporter which is dbms_output
--No tables are used for this.   
--Suite Management packages are when developed will make this easier.
--Clear Screen
Set Serveroutput On Size Unlimited format truncated
set echo off
--install the example unit test packages
@@tst_pkg_huge.pks

alter package tst_pkg_huge compile PLSQL_CCFLAGS = 'tst_slim:true';

declare
  l_suite ut_test_suite;
begin  
  l_suite := ut_suite_manager.config_package(a_owner_name => USER,a_object_name => 'TST_PKG_HUGE');
  dbms_output.put_line('suite_count='||l_suite.items.count);
end;
/
drop package tst_pkg_huge;
