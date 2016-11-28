whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback off
set heading off
set verify off

define ut3_owner   = &1
define ut3_user    = &2
define ut3_syntype = &3

create &ut3_syntype synonym &ut3_user.ut_test                       for &ut3_owner..ut_test;
create &ut3_syntype synonym &ut3_user.ut_reporter                   for &ut3_owner..ut_reporter;
create &ut3_syntype synonym &ut3_user.ut_dbms_output_suite_reporter for &ut3_owner..ut_dbms_output_suite_reporter;
create &ut3_syntype synonym &ut3_user.ut_test_suite                 for &ut3_owner..ut_test_suite;
create &ut3_syntype synonym &ut3_user.ut_suite_manager              for &ut3_owner..ut_suite_manager;

exit success
