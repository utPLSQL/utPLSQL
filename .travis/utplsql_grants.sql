whenever sqlerror  exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback on
set heading off
set verify off

define ut3_user       = &1

--object types
grant execute on ut_object to &ut3_user;
grant execute on ut_assert to &ut3_user;
grant execute on ut_assert_result to &ut3_user;
grant execute on ut_test to &ut3_user;
grant execute on ut_test_suite to &ut3_user;
grant execute on ut_suite_manager to &ut3_user;

grant execute,under on ut_output to &ut3_user;
grant execute       on ut_output_dbms_output to &ut3_user;

grant execute,under on ut_reporter to &ut3_user;
grant execute       on ut_composite_reporter to &ut3_user;
grant execute       on ut_reporters_list to &ut3_user;
grant execute,under on ut_documentation_reporter to &ut3_user;
grant execute,under on ut_teamcity_reporter to &ut3_user;

grant execute on equal to &ut3_user;
grant execute on match to &ut3_user;
grant execute on be_like to &ut3_user;
grant execute on be_true to &ut3_user;
grant execute on be_false to &ut3_user;
grant execute on be_null to &ut3_user;
grant execute on be_not_null to &ut3_user;
grant execute on be_between to &ut3_user;

grant execute on ut_objects_list to &ut3_user;
grant execute on ut_varchar2_list to &ut3_user;

--packages
grant execute on ut to &ut3_user;
grant execute on ut_assert_processor to &ut3_user;
grant execute on ut_utils to &ut3_user;
grant execute on ut_annotations to &ut3_user;
grant execute on ut_metadata to &ut3_user;


exit success
