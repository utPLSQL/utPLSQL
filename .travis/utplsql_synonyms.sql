whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set echo off
set feedback on
set heading off
set verify off

define ut3_owner   = "&1"
define ut3_user    = "&2"
define ut3_syntype = "&3"

create &ut3_syntype synonym &ut3_user.ut_assert                       for &ut3_owner..ut_assert;
create &ut3_syntype synonym &ut3_user.ut_test                       for &ut3_owner..ut_test;
create &ut3_syntype synonym &ut3_user.ut_reporter                   for &ut3_owner..ut_reporter;
create &ut3_syntype synonym &ut3_user.ut_dbms_output_suite_reporter for &ut3_owner..ut_dbms_output_suite_reporter;
create &ut3_syntype synonym &ut3_user.ut_test_suite                 for &ut3_owner..ut_test_suite;
create &ut3_syntype synonym &ut3_user.ut_suite_manager              for &ut3_owner..ut_suite_manager;
create &ut3_syntype synonym &ut3_user.ut_objects_list              for &ut3_owner..ut_objects_list;
create &ut3_syntype synonym &ut3_user.UT_ASSERT_RESULT              for &ut3_owner..UT_ASSERT_RESULT;
create &ut3_syntype synonym &ut3_user.UT_output              for &ut3_owner..UT_output;
create &ut3_syntype synonym &ut3_user.ut_output_dbms_output              for &ut3_owner..ut_output_dbms_output;
create &ut3_syntype synonym &ut3_user.ut_object              for &ut3_owner..ut_object;

create &ut3_syntype synonym &ut3_user.ut_composite_reporter              for &ut3_owner..ut_composite_reporter;
create &ut3_syntype synonym &ut3_user.ut_reporters_list              for &ut3_owner..ut_reporters_list;
create &ut3_syntype synonym &ut3_user.ut_documentation_reporter   for &ut3_owner..ut_documentation_reporter;


create &ut3_syntype synonym &ut3_user.ut              for &ut3_owner..ut;
create &ut3_syntype synonym &ut3_user.ut_assert_processor              for &ut3_owner..ut_assert_processor;
create &ut3_syntype synonym &ut3_user.UT_UTILS              for &ut3_owner..UT_UTILS;

create &ut3_syntype synonym &ut3_user.equal              for &ut3_owner..equal;
create &ut3_syntype synonym &ut3_user.match              for &ut3_owner..match;
create &ut3_syntype synonym &ut3_user.be_like              for &ut3_owner..be_like;
create &ut3_syntype synonym &ut3_user.be_true              for &ut3_owner..be_true;
create &ut3_syntype synonym &ut3_user.be_false              for &ut3_owner..be_false;

create &ut3_syntype synonym &ut3_user.be_null              for &ut3_owner..be_null;
create &ut3_syntype synonym &ut3_user.be_not_null              for &ut3_owner..be_not_null;
create &ut3_syntype synonym &ut3_user.be_between              for &ut3_owner..be_between;

create &ut3_syntype synonym &ut3_user.UT_ANNOTATIONS              for &ut3_owner..UT_ANNOTATIONS;
create &ut3_syntype synonym &ut3_user.UT_metadata              for &ut3_owner..UT_metadata;

create &ut3_syntype synonym &ut3_user.UT_VARCHAR2_LIST              for &ut3_owner..UT_VARCHAR2_LIST;


exit success

