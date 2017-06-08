/*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

Create all necessary grant for the user who owns test packages and want to execute utPLSQL framework
*/

set echo off
set feedback on
set heading off
set verify off

define ut3_owner       = &1
define ut3_user        = &2

prompt Granting privileges on UTPLSQL objects in &&ut3_owner schema to user &&ut3_user

whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set current_schema = &&ut3_owner;

grant execute on &&ut3_owner..ut_be_between to &ut3_user;
grant execute on &&ut3_owner..ut_be_empty to &ut3_user;
grant execute on &&ut3_owner..ut_be_false to &ut3_user;
grant execute on &&ut3_owner..ut_be_greater_or_equal to &ut3_user;
grant execute on &&ut3_owner..ut_be_greater_than to &ut3_user;
grant execute on &&ut3_owner..ut_be_less_or_equal to &ut3_user;
grant execute on &&ut3_owner..ut_be_less_than to &ut3_user;
grant execute on &&ut3_owner..ut_be_like to &ut3_user;
grant execute on &&ut3_owner..ut_be_not_null to &ut3_user;
grant execute on &&ut3_owner..ut_be_null to &ut3_user;
grant execute on &&ut3_owner..ut_be_true to &ut3_user;
grant execute on &&ut3_owner..ut_equal to &ut3_user;
grant execute on &&ut3_owner..ut_match to &ut3_user;
grant execute on &&ut3_owner..ut to &ut3_user;
grant execute on &&ut3_owner..ut_runner to &ut3_user;
grant execute on &&ut3_owner..ut_teamcity_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_xunit_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_documentation_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_html_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_sonar_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coveralls_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_reporters to &ut3_user;
grant execute on &&ut3_owner..ut_varchar2_list to &ut3_user;
grant execute on &&ut3_owner..ut_varchar2_rows to &ut3_user;
grant execute on &&ut3_owner..ut_reporter_base to &ut3_user;
grant execute on &&ut3_owner..ut_coverage to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_options to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_helper to &ut3_user;
grant insert, delete, select on &&ut3_owner..ut_coverage_sources_tmp to &ut3_user;
grant execute on &&ut3_owner..ut_output_buffer to &ut3_user;
grant execute on &&ut3_owner..ut_file_mappings to &ut3_user;
grant execute on &&ut3_owner..ut_file_mapping to &ut3_user;
grant execute on &&ut3_owner..ut_file_mapper to &ut3_user;
grant execute on &&ut3_owner..ut_key_value_pairs to &ut3_user;
grant execute on &&ut3_owner..ut_key_value_pair to &ut3_user;
grant select, insert, delete on &&ut3_owner..ut_cursor_data to &ut3_user;
grant execute on &&ut3_owner..ut_sonar_test_reporter to &ut3_user;

prompt Creating synonyms for UTPLSQL objects in &&ut3_owner schema to user &&ut3_user

create or replace synonym &ut3_user..be_between for &&ut3_owner..be_between;
create or replace synonym &ut3_user..be_empty for &&ut3_owner..be_empty;
create or replace synonym &ut3_user..be_false for &&ut3_owner..be_false;
create or replace synonym &ut3_user..be_greater_or_equal for &&ut3_owner..be_greater_or_equal;
create or replace synonym &ut3_user..be_greater_than for &&ut3_owner..be_greater_than;
create or replace synonym &ut3_user..be_less_or_equal for &&ut3_owner..be_less_or_equal;
create or replace synonym &ut3_user..be_less_than for &&ut3_owner..be_less_than;
create or replace synonym &ut3_user..be_like for &&ut3_owner..be_like;
create or replace synonym &ut3_user..be_not_null for &&ut3_owner..be_not_null;
create or replace synonym &ut3_user..be_null for &&ut3_owner..be_null;
create or replace synonym &ut3_user..be_true for &&ut3_owner..be_true;
create or replace synonym &ut3_user..equal for &&ut3_owner..equal;
create or replace synonym &ut3_user..match for &&ut3_owner..match;
create or replace synonym &ut3_user..ut for &&ut3_owner..ut;
create or replace synonym &ut3_user..ut_runner for &&ut3_owner..ut_runner;
create or replace synonym &ut3_user..ut_teamcity_reporter for &&ut3_owner..ut_teamcity_reporter;
create or replace synonym &ut3_user..ut_xunit_reporter for &&ut3_owner..ut_xunit_reporter;
create or replace synonym &ut3_user..ut_documentation_reporter for &&ut3_owner..ut_documentation_reporter;
create or replace synonym &ut3_user..ut_coverage_html_reporter for &&ut3_owner..ut_coverage_html_reporter;
create or replace synonym &ut3_user..ut_coverage_sonar_reporter for &&ut3_owner..ut_coverage_sonar_reporter;
create or replace synonym &ut3_user..ut_coveralls_reporter for &&ut3_owner..ut_coveralls_reporter;
create or replace synonym &ut3_user..ut_reporters for &&ut3_owner..ut_reporters;
create or replace synonym &ut3_user..ut_varchar2_list for &&ut3_owner..ut_varchar2_list;
create or replace synonym &ut3_user..ut_varchar2_rows for &&ut3_owner..ut_varchar2_rows;
create or replace synonym &ut3_user..ut_reporter_base for &&ut3_owner..ut_reporter_base;
create or replace synonym &ut3_user..ut_coverage for &&ut3_owner..ut_coverage;
create or replace synonym &ut3_user..ut_coverage_options for &&ut3_owner..ut_coverage_options;
create or replace synonym &ut3_user..ut_coverage_helper for &&ut3_owner..ut_coverage_helper;
create or replace synonym &ut3_user..ut_coverage_sources_tmp for &&ut3_owner..ut_coverage_sources_tmp;
create or replace synonym &ut3_user..ut_output_buffer for &&ut3_owner..ut_output_buffer;
create or replace synonym &ut3_user..ut_file_mappings for &&ut3_owner..ut_file_mappings;
create or replace synonym &ut3_user..ut_file_mapping for &&ut3_owner..ut_file_mapping;
create or replace synonym &ut3_user..ut_file_mapper for &&ut3_owner..ut_file_mapper;
create or replace synonym &ut3_user..ut_key_value_pairs for &&ut3_owner..ut_key_value_pairs;
create or replace synonym &ut3_user..ut_key_value_pair for &&ut3_owner..ut_key_value_pair;
create or replace synonym &ut3_user..ut_cursor_data for &&ut3_owner..ut_cursor_data;
create or replace synonym &ut3_user..ut_sonar_test_reporter for &&ut3_owner..ut_sonar_test_reporter;
