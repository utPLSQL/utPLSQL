create or replace package ut_file_mapper authid current_user is
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
  */

  gc_file_mapping_regex        constant varchar2(100) := '.*(\\|\/)((\w+)\.)?(\w+)\.(\w{3})';
  gc_regex_owner_subexpression constant positive := 3;
  gc_regex_name_subexpression  constant positive := 4;
  gc_regex_type_subexpression  constant positive := 5;

  function default_file_to_obj_type_map return ut_key_value_pairs;

  function build_file_mappings(
    a_file_paths                  ut_varchar2_list,
    a_file_to_object_type_mapping ut_key_value_pairs := null,
    a_regex_pattern               varchar2 := null,
    a_object_owner_subexpression  positive := null,
    a_object_name_subexpression   positive := null,
    a_object_type_subexpression   positive := null
  ) return ut_file_mappings;

  function build_file_mappings(
    a_object_owner                varchar2,
    a_file_paths                  ut_varchar2_list,
    a_file_to_object_type_mapping ut_key_value_pairs := null,
    a_regex_pattern               varchar2 := null,
    a_object_owner_subexpression  positive := null,
    a_object_name_subexpression   positive := null,
    a_object_type_subexpression   positive := null
  ) return ut_file_mappings;


end;
/
