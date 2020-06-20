/*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
    when '&&2' is null then q'[ACCEPT ut3_user CHAR DEFAULT 'PUBLIC' PROMPT 'Provide schema which should own synonyms for the utPLSQL v3 framework (PUBLIC): ']'
    else 'define ut3_user=&&2.'
  end
from dual;
spool off
set termout on
@params.sql.tmp
set termout off

spool params.sql.tmp
select
  case
    when upper('&&ut3_user') = 'PUBLIC' then q'[define action_type='or replace public'
      ]'||q'[define ut3_user=''
      ]'||q'[define grantee='PUBLIC']'
    else q'[define action_type='or replace'
      ]'||q'[define grantee='&&ut3_user']
      ]'||q'[define ut3_user='&&ut3_user..']'
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

whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

alter session set current_schema = &&ut3_owner;

prompt Creating synonyms for UTPLSQL objects in &&ut3_owner schema to user &&grantee

--public API
create &action_type. synonym &ut3_user.ut for &&ut3_owner..ut;
create &action_type. synonym &ut3_user.ut_runner for &&ut3_owner..ut_runner;
create &action_type. synonym &ut3_user.ut_file_mappings for &&ut3_owner..ut_file_mappings;
create &action_type. synonym &ut3_user.ut_file_mapping for &&ut3_owner..ut_file_mapping;
create &action_type. synonym &ut3_user.ut_file_mapper for &&ut3_owner..ut_file_mapper;
create &action_type. synonym &ut3_user.ut_suite_items_info for &&ut3_owner..ut_suite_items_info;
create &action_type. synonym &ut3_user.ut_suite_item_info for &&ut3_owner..ut_suite_item_info;
create &action_type. synonym &ut3_user.ut_run_info for &&ut3_owner..ut_run_info;

--generic types
create &action_type. synonym &ut3_user.ut_varchar2_list for &&ut3_owner..ut_varchar2_list;
create &action_type. synonym &ut3_user.ut_varchar2_rows for &&ut3_owner..ut_varchar2_rows;
create &action_type. synonym &ut3_user.ut_integer_list for &&ut3_owner..ut_integer_list;
create &action_type. synonym &ut3_user.ut_key_value_pairs for &&ut3_owner..ut_key_value_pairs;
create &action_type. synonym &ut3_user.ut_key_value_pair for &&ut3_owner..ut_key_value_pair;

--expectations
create &action_type. synonym &ut3_user.ut_expectation for &&ut3_owner..ut_expectation;
create &action_type. synonym &ut3_user.ut_expectation_compound for &&ut3_owner..ut_expectation_compound;
create &action_type. synonym &ut3_user.ut_expectation_json for &&ut3_owner..ut_expectation_json;

--matchers
create &action_type. synonym &ut3_user.ut_matcher for &&ut3_owner..ut_matcher;
create &action_type. synonym &ut3_user.be_between for &&ut3_owner..be_between;
create &action_type. synonym &ut3_user.be_empty for &&ut3_owner..be_empty;
create &action_type. synonym &ut3_user.be_false for &&ut3_owner..be_false;
create &action_type. synonym &ut3_user.be_greater_or_equal for &&ut3_owner..be_greater_or_equal;
create &action_type. synonym &ut3_user.be_greater_than for &&ut3_owner..be_greater_than;
create &action_type. synonym &ut3_user.be_less_or_equal for &&ut3_owner..be_less_or_equal;
create &action_type. synonym &ut3_user.be_less_than for &&ut3_owner..be_less_than;
create &action_type. synonym &ut3_user.be_like for &&ut3_owner..be_like;
create &action_type. synonym &ut3_user.be_not_null for &&ut3_owner..be_not_null;
create &action_type. synonym &ut3_user.be_null for &&ut3_owner..be_null;
create &action_type. synonym &ut3_user.be_true for &&ut3_owner..be_true;
create &action_type. synonym &ut3_user.be_within for &&ut3_owner..be_within;
create &action_type. synonym &ut3_user.be_within_pct for &&ut3_owner..be_within_pct;
create &action_type. synonym &ut3_user.contain for &&ut3_owner..contain;
create &action_type. synonym &ut3_user.equal for &&ut3_owner..equal;
create &action_type. synonym &ut3_user.have_count for &&ut3_owner..have_count;
create &action_type. synonym &ut3_user.match for &&ut3_owner..match;

--reporters - test results
create &action_type. synonym &ut3_user.ut_teamcity_reporter for &&ut3_owner..ut_teamcity_reporter;
create &action_type. synonym &ut3_user.ut_xunit_reporter for &&ut3_owner..ut_xunit_reporter;
create &action_type. synonym &ut3_user.ut_junit_reporter for &&ut3_owner..ut_junit_reporter;
create &action_type. synonym &ut3_user.ut_tfs_junit_reporter for &&ut3_owner..ut_tfs_junit_reporter;
create &action_type. synonym &ut3_user.ut_documentation_reporter for &&ut3_owner..ut_documentation_reporter;
create &action_type. synonym &ut3_user.ut_sonar_test_reporter for &&ut3_owner..ut_sonar_test_reporter;
create &action_type. synonym &ut3_user.ut_realtime_reporter for &&ut3_owner..ut_realtime_reporter;
--reporters - coverage
create &action_type. synonym &ut3_user.ut_coverage_html_reporter for &&ut3_owner..ut_coverage_html_reporter;
create &action_type. synonym &ut3_user.ut_coverage_sonar_reporter for &&ut3_owner..ut_coverage_sonar_reporter;
create &action_type. synonym &ut3_user.ut_coveralls_reporter for &&ut3_owner..ut_coveralls_reporter;
create &action_type. synonym &ut3_user.ut_coverage_cobertura_reporter for &&ut3_owner..ut_coverage_cobertura_reporter;
--reporters - debug
create &action_type. synonym &ut3_user.ut_debug_reporter for &&ut3_owner..ut_debug_reporter;
--reporters - base types
create &action_type. synonym &ut3_user.ut_reporters for &&ut3_owner..ut_reporters;
create &action_type. synonym &ut3_user.ut_reporter_base for &&ut3_owner..ut_reporter_base;
create &action_type. synonym &ut3_user.ut_output_reporter_base for &&ut3_owner..ut_output_reporter_base;

--other synonyms
create &action_type. synonym &ut3_user.dbmspcc_blocks for &&ut3_owner..dbmspcc_blocks;
create &action_type. synonym &ut3_user.dbmspcc_runs for &&ut3_owner..dbmspcc_runs;
create &action_type. synonym &ut3_user.dbmspcc_units for &&ut3_owner..dbmspcc_units;
