create or replace package ut_coverage authid current_user is
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
  */

  -- total run coverage information
  subtype t_full_name   is varchar2(500);
  subtype t_object_name is varchar2(250);

  subtype t_line_executions is binary_integer;
  -- line coverage information indexed by line no.
  type tt_lines is table of t_line_executions index by binary_integer;
  --unit coverage information record
  type t_unit_coverage is record (
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0) := 0,
    lines           tt_lines
  );

  -- coverage information indexed by full object name (schema.object)
  type tt_program_units is table of t_unit_coverage index by t_full_name;

  -- total run coverage information
  type t_coverage is record(
    covered_lines   binary_integer := 0,
    uncovered_lines binary_integer := 0,
    total_lines     binary_integer := 0,
    executions      number(38,0)   := 0,
    objects         tt_program_units
  );

  function  get_coverage_id return integer;

  function  coverage_start return integer;
  procedure coverage_start;

  /*
  * Start coverage in develop mode, where all internal calls to utPLSQL itself are also included
  */
  procedure coverage_start_develop;

  procedure coverage_stop;

  procedure coverage_pause;

  procedure coverage_resume;

  procedure coverage_flush;

  procedure skip_coverage_for(a_object ut_object_name);

  function get_coverage_data(a_schema_names ut_varchar2_list) return t_coverage;

  function get_schema_names_from_run(a_run ut_run) return ut_varchar2_list;

end;
/
