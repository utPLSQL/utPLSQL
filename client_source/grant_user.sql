/*
Create all necessary grant for the user who owns test packages and want to execute utPLSQL framework
*/

prompt Granting user
set echo off
set feedback off
set heading off
set verify off

define ut3_owner       = &1
define ut3_user        = &2

grant execute on &ut3_owner .be_between to &ut3_user;
grant execute on &ut3_owner .be_false to &ut3_user;
grant execute on &ut3_owner .be_greater_or_equal to &ut3_user;
grant execute on &ut3_owner .be_greater_than to &ut3_user;
grant execute on &ut3_owner .be_less_or_equal to &ut3_user;
grant execute on &ut3_owner .be_less_than to &ut3_user;
grant execute on &ut3_owner .be_like to &ut3_user;
grant execute on &ut3_owner .be_not_null to &ut3_user;
grant execute on &ut3_owner .be_null to &ut3_user;
grant execute on &ut3_owner .be_true to &ut3_user;
grant execute on &ut3_owner .equal to &ut3_user;
grant execute on &ut3_owner .match to &ut3_user;
grant execute on &ut3_owner .ut to &ut3_user;
grant execute on &ut3_owner .ut_runner to &ut3_user;
grant execute on &ut3_owner .ut_teamcity_reporter to &ut3_user;
grant execute on &ut3_owner .ut_documentation_reporter to &ut3_user;
grant execute on &ut3_owner .ut_reporters to &ut3_user;
grant execute on &ut3_owner .ut_assert_processor to &ut3_user;

create or replace synonym &ut3_user .be_between for &ut3_owner .be_between;
create or replace synonym &ut3_user .be_false for &ut3_owner .be_false;
create or replace synonym &ut3_user .be_greater_or_equal for &ut3_owner .be_greater_or_equal;
create or replace synonym &ut3_user .be_greater_than for &ut3_owner .be_greater_than;
create or replace synonym &ut3_user .be_less_or_equal for &ut3_owner .be_less_or_equal;
create or replace synonym &ut3_user .be_less_than for &ut3_owner .be_less_than;
create or replace synonym &ut3_user .be_like for &ut3_owner .be_like;
create or replace synonym &ut3_user .be_not_null for &ut3_owner .be_not_null;
create or replace synonym &ut3_user .be_null for &ut3_owner .be_null;
create or replace synonym &ut3_user .be_true for &ut3_owner .be_true;
create or replace synonym &ut3_user .equal for &ut3_owner .equal;
create or replace synonym &ut3_user .match for &ut3_owner .match;
create or replace synonym &ut3_user .ut for &ut3_owner .ut;
create or replace synonym &ut3_user .ut_runner for &ut3_owner .ut_runner;
create or replace synonym &ut3_user .ut_teamcity_reporter for &ut3_owner .ut_teamcity_reporter;
create or replace synonym &ut3_user .ut_documentation_reporter for &ut3_owner .ut_documentation_reporter;
create or replace synonym &ut3_user .ut_reporters for &ut3_owner .ut_reporters;
create or replace synonym &ut3_user .ut_assert_processor for &ut3_owner .ut_assert_processor;

