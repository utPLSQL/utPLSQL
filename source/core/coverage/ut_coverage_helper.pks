create or replace package ut_coverage_helper authid definer is
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
  */

  --table of line calls indexed by line number
  --!!! this table is sparse!!!
  --type t_unit_line_calls is table of number(38,0) index by binary_integer;

  type t_unit_line_call is record(
     blocks         binary_integer default 0
    ,covered_blocks binary_integer default 0
    ,partcovered    binary_integer default 0
    ,calls          binary_integer default 0);

  type t_unit_line_calls is table of t_unit_line_call index by binary_integer;

  type t_coverage_sources_tmp_row is record (
    full_name      ut_coverage_sources_tmp.full_name%type,
    owner          ut_coverage_sources_tmp.owner%type,
    name           ut_coverage_sources_tmp.name%type,
    line           ut_coverage_sources_tmp.line%type,
    to_be_skipped  ut_coverage_sources_tmp.to_be_skipped%type,
    text           ut_coverage_sources_tmp.text%type
  );

  type t_coverage_sources_tmp_rows is table of t_coverage_sources_tmp_row;

  type t_tmp_table_object is record(
    owner              ut_coverage_sources_tmp.owner%type,
    name               ut_coverage_sources_tmp.name%type,
    full_name          ut_coverage_sources_tmp.full_name%type,
    lines_count        integer,
    to_be_skipped_list ut_varchar2_list
  );

  type t_tmp_table_objects_crsr is ref cursor return t_tmp_table_object;

  procedure insert_into_tmp_table(a_data t_coverage_sources_tmp_rows);

  procedure cleanup_tmp_table;

  function is_tmp_table_populated return boolean;

  function get_tmp_table_objects_cursor return t_tmp_table_objects_crsr;

  function get_tmp_table_object_lines(a_owner varchar2, a_object_name varchar2) return ut_varchar2_list;

  procedure set_coverage_run_ids( a_coverage_run_id raw, a_line_coverage_id integer, a_block_coverage_id integer );

end;
/
