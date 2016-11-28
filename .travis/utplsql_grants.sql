whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback off
set heading off
set verify off

define ut3_user       = &1

grant execute on ut_assert to &ut3_user;
grant execute on ut_test to &ut3_user;
grant execute on ut_reporter to &ut3_user;
grant execute on UT_DBMS_OUTPUT_SUITE_REPORTER to &ut3_user;
grant execute on ut_test_suite to &ut3_user;
grant execute on ut_suite_manager to &ut3_user;


exit success
