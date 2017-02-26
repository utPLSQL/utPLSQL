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

  gc_file_mapping_regex        constant varchar2(100) := '.*(\\|\/)((\w+)\.)?(\w+)\.(\w{3})';
  gc_regex_owner_subexpression constant positive := 3;
  gc_regex_name_subexpression  constant positive := 4;
  gc_regex_type_subexpression  constant positive := 5;

  -- total run coverage information
  subtype t_full_name   is varchar2(500);
  subtype t_object_name is varchar2(250);

  subtype t_line_executions is binary_integer;
  -- line coverage information indexed by line no.
  type tt_lines is table of t_line_executions index by binary_integer;
  --unit coverage information record
  type t_unit_coverage is record (
    owner           varchar2(128),
    name            varchar2(128),
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

  function default_file_to_obj_type_map return ut_key_value_pairs;

  function build_file_mappings(
    a_object_owner                varchar2,
    a_file_paths                  ut_varchar2_list,
    a_file_to_object_type_mapping ut_key_value_pairs := default_file_to_obj_type_map(),
    a_regex_pattern               varchar2 := gc_file_mapping_regex,
    a_object_owner_subexpression  positive := gc_regex_owner_subexpression,
    a_object_name_subexpression   positive := gc_regex_name_subexpression,
    a_object_type_subexpression   positive := gc_regex_type_subexpression
  ) return ut_coverage_file_mappings;

  function get_include_schema_names return ut_varchar2_list;

  procedure set_include_schema_names(a_schema_names ut_varchar2_list);

  procedure init(
    a_schema_names        ut_varchar2_list,
    a_include_object_list ut_varchar2_list,
    a_exclude_object_list ut_varchar2_list
  );

  procedure init(
    a_file_mappings       ut_coverage_file_mappings,
    a_include_object_list ut_varchar2_list,
    a_exclude_object_list ut_varchar2_list
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

  procedure skip_coverage_for(a_ut_objects ut_object_names);

  function get_coverage_data return t_coverage;

end;
/
