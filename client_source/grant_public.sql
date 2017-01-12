/*
Create all necessary grant for the user who owns test packages and want to execute utPLSQL framework
*/

prompt Granting user
set echo off
set feedback off
set heading off
set verify off

define ut3_owner       = &1

grant execute on &ut3_owner .ut_be_between to public;
grant execute on &ut3_owner .ut_be_false to public;
grant execute on &ut3_owner .ut_be_greater_or_equal to public;
grant execute on &ut3_owner .ut_be_greater_than to public;
grant execute on &ut3_owner .ut_be_less_or_equal to public;
grant execute on &ut3_owner .ut_be_less_than to public;
grant execute on &ut3_owner .ut_be_like to public;
grant execute on &ut3_owner .ut_be_not_null to public;
grant execute on &ut3_owner .ut_be_null to public;
grant execute on &ut3_owner .ut_be_true to public;
grant execute on &ut3_owner .ut_equal to public;
grant execute on &ut3_owner .ut_match to public;
grant execute on &ut3_owner .ut to public;
grant execute on &ut3_owner .ut_runner to public;
grant execute on &ut3_owner .ut_teamcity_reporter to public;
grant execute on &ut3_owner .ut_documentation_reporter to public;
grant execute on &ut3_owner .ut_reporters to public;

create or replace public synonym be_between for &ut3_owner .ut_be_between;
create or replace public synonym be_false for &ut3_owner .ut_be_false;
create or replace public synonym be_greater_or_equal for &ut3_owner .ut_be_greater_or_equal;
create or replace public synonym be_greater_than for &ut3_owner .ut_be_greater_than;
create or replace public synonym be_less_or_equal for &ut3_owner .ut_be_less_or_equal;
create or replace public synonym be_less_than for &ut3_owner .ut_be_less_than;
create or replace public synonym be_like for &ut3_owner .ut_be_like;
create or replace public synonym be_not_null for &ut3_owner .ut_be_not_null;
create or replace public synonym be_null for &ut3_owner .ut_be_null;
create or replace public synonym be_true for &ut3_owner .ut_be_true;
create or replace public synonym equal for &ut3_owner .ut_equal;
create or replace public synonym match for &ut3_owner .ut_match;
create or replace public synonym ut for &ut3_owner .ut;
create or replace public synonym ut_runner for &ut3_owner .ut_runner;
create or replace public synonym ut_teamcity_reporter for &ut3_owner .ut_teamcity_reporter;
create or replace public synonym ut_documentation_reporter for &ut3_owner .ut_documentation_reporter;
create or replace public synonym ut_reporters for &ut3_owner .ut_reporters;
