/*
Create all necessary grant for the user who owns test packages and want to execute utPLSQL framework
*/

set echo off
set feedback on
set heading off
set verify off

define ut3_owner       = &1
define ut3_user        = &2

prompt Granting privileges on UTPLSQL objects in &&ut3_owner schema to user &&ut3_user
alter session set current_schema = &&ut3_owner;

grant execute on ut_be_between to &ut3_user;
grant execute on ut_be_false to &ut3_user;
grant execute on ut_be_greater_or_equal to &ut3_user;
grant execute on ut_be_greater_than to &ut3_user;
grant execute on ut_be_less_or_equal to &ut3_user;
grant execute on ut_be_less_than to &ut3_user;
grant execute on ut_be_like to &ut3_user;
grant execute on ut_be_not_null to &ut3_user;
grant execute on ut_be_null to &ut3_user;
grant execute on ut_be_true to &ut3_user;
grant execute on ut_equal to &ut3_user;
grant execute on ut_match to &ut3_user;
grant execute on ut to &ut3_user;
grant execute on ut_runner to &ut3_user;
grant execute on ut_teamcity_reporter to &ut3_user;
grant execute on ut_xunit_reporter to &ut3_user;
grant execute on ut_documentation_reporter to &ut3_user;
grant execute on ut_coverage_html_reporter to &ut3_user;
grant execute on ut_reporters to &ut3_user;
grant execute on ut_varchar2_list to &ut3_user;
grant execute on ut_reporter_base to &ut3_user;
grant execute on ut_coverage to &ut3_user;
grant execute on ut_coverage_helper to &ut3_user;
grant execute on ut_coverage_row to &ut3_user;
grant execute on ut_coverage_rows to &ut3_user;
grant execute on ut_output_buffer to &ut3_user;

prompt Creating synonyms for UTPLSQL objects in &&ut3_owner schema to user &&ut3_user

create or replace synonym &ut3_user .be_between for be_between;
create or replace synonym &ut3_user .be_false for be_false;
create or replace synonym &ut3_user .be_greater_or_equal for be_greater_or_equal;
create or replace synonym &ut3_user .be_greater_than for be_greater_than;
create or replace synonym &ut3_user .be_less_or_equal for be_less_or_equal;
create or replace synonym &ut3_user .be_less_than for be_less_than;
create or replace synonym &ut3_user .be_like for be_like;
create or replace synonym &ut3_user .be_not_null for be_not_null;
create or replace synonym &ut3_user .be_null for be_null;
create or replace synonym &ut3_user .be_true for be_true;
create or replace synonym &ut3_user .equal for equal;
create or replace synonym &ut3_user .match for match;
create or replace synonym &ut3_user .ut for ut;
create or replace synonym &ut3_user .ut_runner for ut_runner;
create or replace synonym &ut3_user .ut_teamcity_reporter for ut_teamcity_reporter;
create or replace synonym &ut3_user .ut_xunit_reporter for ut_xunit_reporter;
create or replace synonym &ut3_user .ut_documentation_reporter for ut_documentation_reporter;
create or replace synonym &ut3_user .ut_coverage_html_reporter for ut_coverage_html_reporter;
create or replace synonym &ut3_user .ut_reporters for ut_reporters;
create or replace synonym &ut3_user .ut_varchar2_list for ut_varchar2_list;
create or replace synonym &ut3_user .ut_reporter_base for ut_reporter_base;
create or replace synonym &ut3_user .ut_coverage for ut_coverage;
create or replace synonym &ut3_user .ut_coverage_helper for ut_coverage_helper;
create or replace synonym &ut3_user .ut_coverage_row for ut_coverage_row;
create or replace synonym &ut3_user .ut_coverage_rows for ut_coverage_rows;
create or replace synonym &ut3_user .ut_output_buffer for ut_output_buffer;
