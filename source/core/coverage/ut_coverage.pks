create or replace package ut_coverage authid current_user is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  subtype t_coverage_run_id is raw(32) not null;

  -- total run coverage information
  subtype t_object_name is varchar2(257);
  subtype t_line_no is binary_integer;

  type t_line_executions is record(
     executions     binary_integer
    ,partcove       binary_integer
    ,no_blocks      binary_integer
    ,covered_blocks binary_integer);

  -- line coverage information indexed by line no.
  type tt_lines is table of t_line_executions index by t_line_no;

  --unit coverage information record
  type t_unit_coverage is record(
     owner             varchar2(128)
    ,name              varchar2(128)
    ,covered_lines     binary_integer := 0
    ,uncovered_lines   binary_integer := 0
    ,partcovered_lines binary_integer := 0
    ,total_blocks      binary_integer default null
    ,covered_blocks    binary_integer default null
    ,uncovered_blocks  binary_integer default null
    ,total_lines       binary_integer := 0
    ,executions        number(38, 0) := 0
    ,lines             tt_lines);

  -- coverage information indexed by full object name (schema.object)
  type tt_program_units is table of t_unit_coverage index by t_object_name;

  -- total run coverage information
  type t_coverage is record(
     covered_lines     binary_integer := 0
    ,uncovered_lines   binary_integer := 0
    ,partcovered_lines binary_integer := 0
    ,total_lines       binary_integer default null
    ,total_blocks      binary_integer default null
    ,covered_blocks    binary_integer default null
    ,uncovered_blocks  binary_integer default null
    ,executions        number(38, 0) := 0
    ,objects           tt_program_units);

  procedure set_develop_mode(a_develop_mode in boolean);

  function is_develop_mode return boolean;

  procedure coverage_start(a_coverage_run_id t_coverage_run_id);

  procedure coverage_stop;

  procedure coverage_pause;

  procedure coverage_resume;

  function get_coverage_data(a_coverage_options ut_coverage_options) return t_coverage;

end;
/
