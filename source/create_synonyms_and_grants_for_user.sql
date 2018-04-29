/*
  utPLSQL - Version 3
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

@@define_ut3_owner_param.sql

column 2 new_value 2 noprint
select null as "2" from dual where 1=0;
spool params.sql.tmp
select
  case
    when '&&2' is null then q'[ACCEPT ut3_user CHAR PROMPT 'Provide schema name where synonyms for the utPLSQL v3 should be created ']'
    else 'define ut3_user=&&2'
  end
from dual;
spool off
set termout on
@params.sql.tmp
set termout off
/* cleanup temporary sql files */
--try running on windows
$ del params.sql.tmp
--try running on linux/unix
! rm params.sql.tmp
set termout on

set echo off
set feedback on
set heading off
set verify off

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
grant execute on &&ut3_owner..ut_have_count to &ut3_user;
grant execute on &&ut3_owner..ut_match to &ut3_user;
grant execute on &&ut3_owner..ut to &ut3_user;
grant execute on &&ut3_owner..ut_runner to &ut3_user;
grant execute on &&ut3_owner..ut_teamcity_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_xunit_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_junit_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_tfs_junit_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_documentation_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_html_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_sonar_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coveralls_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_cobertura_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_reporters to &ut3_user;
grant execute on &&ut3_owner..ut_varchar2_list to &ut3_user;
grant execute on &&ut3_owner..ut_varchar2_rows to &ut3_user;
grant execute on &&ut3_owner..ut_integer_list to &ut3_user;
grant execute on &&ut3_owner..ut_reporter_base to &ut3_user;
grant execute on &&ut3_owner..ut_output_reporter_base to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_reporter_base to &ut3_user;
grant execute on &&ut3_owner..ut_console_reporter_base to &ut3_user;
grant execute on &&ut3_owner..ut_coverage to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_options to &ut3_user;
grant execute on &&ut3_owner..ut_coverage_helper to &ut3_user;
grant execute on &&ut3_owner..ut_output_buffer_base to &ut3_user;
grant execute on &&ut3_owner..ut_output_table_buffer to &ut3_user;
grant execute on &&ut3_owner..ut_file_mappings to &ut3_user;
grant execute on &&ut3_owner..ut_file_mapping to &ut3_user;
grant execute on &&ut3_owner..ut_file_mapper to &ut3_user;
grant execute on &&ut3_owner..ut_key_value_pairs to &ut3_user;
grant execute on &&ut3_owner..ut_key_value_pair to &ut3_user;
grant select, insert, delete on &&ut3_owner..ut_compound_data_tmp to &ut3_user;
grant select, insert, delete on &&ut3_owner..ut_compound_data_diff_tmp to &ut3_user;
grant execute on &&ut3_owner..ut_sonar_test_reporter to &ut3_user;
grant execute on &&ut3_owner..ut_annotations to &ut3_user;
grant execute on &&ut3_owner..ut_annotation to &ut3_user;
grant execute on &&ut3_owner..ut_annotation_manager to &ut3_user;
grant execute on &&ut3_owner..ut_annotated_object to &ut3_user;
grant execute on &&ut3_owner..ut_annotated_objects to &ut3_user;
grant select on &&ut3_owner..ut_annotation_cache_info to &ut3_user;
grant select on &&ut3_owner..ut_annotation_cache to &ut3_user;
grant execute on &&ut3_owner..ut_annotation_cache_manager to &ut3_user;
grant execute on &&ut3_owner..ut_annotation_parser to &ut3_user;
grant execute on &&ut3_owner..ut_annotation_objs_cache_info to &ut3_user;
grant execute on &&ut3_owner..ut_annotation_obj_cache_info to &ut3_user;
begin
  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
  execute immediate 'grant select, insert, delete, update on &&ut3_owner..dbmspcc_blocks to &ut3_user';
  execute immediate 'grant select, insert, delete, update on &&ut3_owner..dbmspcc_runs to &ut3_user';
  execute immediate 'grant select, insert, delete, update on &&ut3_owner..dbmspcc_units to &ut3_user';
  $else
  null;
  $end
end;
/


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
create or replace synonym &ut3_user..have_count for &&ut3_owner..have_count;
create or replace synonym &ut3_user..match for &&ut3_owner..match;
create or replace synonym &ut3_user..ut for &&ut3_owner..ut;
create or replace synonym &ut3_user..ut_runner for &&ut3_owner..ut_runner;
create or replace synonym &ut3_user..ut_teamcity_reporter for &&ut3_owner..ut_teamcity_reporter;
create or replace synonym &ut3_user..ut_xunit_reporter for &&ut3_owner..ut_xunit_reporter;
create or replace synonym &ut3_user..ut_junit_reporter for &&ut3_owner..ut_junit_reporter;
create or replace synonym &ut3_user..ut_tfs_junit_reporter for &&ut3_owner..ut_tfs_junit_reporter;
create or replace synonym &ut3_user..ut_documentation_reporter for &&ut3_owner..ut_documentation_reporter;
create or replace synonym &ut3_user..ut_coverage_html_reporter for &&ut3_owner..ut_coverage_html_reporter;
create or replace synonym &ut3_user..ut_coverage_sonar_reporter for &&ut3_owner..ut_coverage_sonar_reporter;
create or replace synonym &ut3_user..ut_coveralls_reporter for &&ut3_owner..ut_coveralls_reporter;
create or replace synonym &ut3_user..ut_coverage_cobertura_reporter for &&ut3_owner..ut_coverage_cobertura_reporter;
create or replace synonym &ut3_user..ut_reporters for &&ut3_owner..ut_reporters;
create or replace synonym &ut3_user..ut_varchar2_list for &&ut3_owner..ut_varchar2_list;
create or replace synonym &ut3_user..ut_varchar2_rows for &&ut3_owner..ut_varchar2_rows;
create or replace synonym &ut3_user..ut_integer_list for &&ut3_owner..ut_integer_list;
create or replace synonym &ut3_user..ut_reporter_base for &&ut3_owner..ut_reporter_base;
create or replace synonym &ut3_user..ut_output_reporter_base for &&ut3_owner..ut_output_reporter_base;
create or replace synonym &ut3_user..ut_coverage for &&ut3_owner..ut_coverage;
create or replace synonym &ut3_user..ut_coverage_options for &&ut3_owner..ut_coverage_options;
create or replace synonym &ut3_user..ut_coverage_helper for &&ut3_owner..ut_coverage_helper;
create or replace synonym &ut3_user..ut_output_buffer_base for &&ut3_owner..ut_output_buffer_base;
create or replace synonym &ut3_user..ut_output_table_buffer for &&ut3_owner..ut_output_table_buffer;
create or replace synonym &ut3_user..ut_file_mappings for &&ut3_owner..ut_file_mappings;
create or replace synonym &ut3_user..ut_file_mapping for &&ut3_owner..ut_file_mapping;
create or replace synonym &ut3_user..ut_file_mapper for &&ut3_owner..ut_file_mapper;
create or replace synonym &ut3_user..ut_key_value_pairs for &&ut3_owner..ut_key_value_pairs;
create or replace synonym &ut3_user..ut_key_value_pair for &&ut3_owner..ut_key_value_pair;
create or replace synonym &ut3_user..ut_compound_data_tmp for &&ut3_owner..ut_cursor_data;
create or replace synonym &ut3_user..ut_compound_data_diff_tmp for &&ut3_owner..ut_compound_data_diff_tmp;
create or replace synonym &ut3_user..ut_sonar_test_reporter for &&ut3_owner..ut_sonar_test_reporter;
begin
  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
  execute immediate 'create or replace synonym &ut3_user..dbmspcc_blocks for &&ut3_owner..dbmspcc_blocks';
  execute immediate 'create or replace synonym &ut3_user..dbmspcc_runs for &&ut3_owner..dbmspcc_runs';
  execute immediate 'create or replace synonym &ut3_user..dbmspcc_units for &&ut3_owner..dbmspcc_units';
  $else
  null;
  $end
end;
/
