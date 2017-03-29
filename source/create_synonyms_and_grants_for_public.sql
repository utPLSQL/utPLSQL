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

define ut3_owner = &1
alter session set current_schema = &&ut3_owner;

prompt Granting privileges on UTPLSQL objects in &&ut3_owner schema to PUBLIC

grant execute on ut_be_within to public;
grant execute on ut_be_between to public;
grant execute on ut_be_empty to public;
grant execute on ut_be_false to public;
grant execute on ut_be_greater_or_equal to public;
grant execute on ut_be_greater_than to public;
grant execute on ut_be_less_or_equal to public;
grant execute on ut_be_less_than to public;
grant execute on ut_be_like to public;
grant execute on ut_be_not_null to public;
grant execute on ut_be_null to public;
grant execute on ut_be_true to public;
grant execute on ut_equal to public;
grant execute on ut_match to public;
grant execute on ut to public;
grant execute on ut_runner to public;
grant execute on ut_teamcity_reporter to public;
grant execute on ut_xunit_reporter to public;
grant execute on ut_documentation_reporter to public;
grant execute on ut_reporters to public;
grant execute on ut_varchar2_list to public;
grant execute on ut_reporter_base to public;

prompt Creating synonyms for UTPLSQL objects in &&ut3_owner schema to PUBLIC

create public synonym be_within for ut_be_within;
create public synonym be_between for ut_be_between;
create public synonym be_empty for ut_be_empty;
create public synonym be_false for ut_be_false;
create public synonym be_greater_or_equal for ut_be_greater_or_equal;
create public synonym be_greater_than for ut_be_greater_than;
create public synonym be_less_or_equal for ut_be_less_or_equal;
create public synonym be_less_than for ut_be_less_than;
create public synonym be_like for ut_be_like;
create public synonym be_not_null for ut_be_not_null;
create public synonym be_null for ut_be_null;
create public synonym be_true for ut_be_true;
create public synonym equal for ut_equal;
create public synonym match for ut_match;
create public synonym ut for ut;
create public synonym ut_runner for ut_runner;
create public synonym ut_teamcity_reporter for ut_teamcity_reporter;
create public synonym ut_xunit_reporter for ut_xunit_reporter;
create public synonym ut_documentation_reporter for ut_documentation_reporter;
create public synonym ut_reporters for ut_reporters;
create public synonym ut_varchar2_list for ut_varchar2_list;
create public synonym ut_reporter_base for ut_reporter_base;
