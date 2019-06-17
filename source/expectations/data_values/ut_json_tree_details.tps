create or replace type ut_json_tree_details force as object (
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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
  json_tree_info  ut_json_leaf_tab,
  member function get_json_type(a_json_piece json_element_t) return varchar2,
  member function get_json_value(a_json_piece json_element_t,a_key varchar2) return varchar2,
  member function get_json_value(a_json_piece json_element_t,a_key integer) return varchar2,
  member procedure add_json_leaf(
    self in out nocopy ut_json_tree_details,
    a_element_name varchar2,
    a_element_value varchar2,
    a_parent_name varchar2,
    a_access_path varchar2,
    a_hierarchy_level integer,
    a_index_position integer,
    a_json_type in varchar2,
    a_parent_type in varchar2,
    a_array_element integer := 0,
    a_parent_path varchar2
  ),
  member procedure traverse_object(
   self in out nocopy ut_json_tree_details,
   a_json_piece json_element_t,
   a_parent_name varchar2 := null,
   a_hierarchy_level integer := 1,
   a_access_path varchar2 := '$'
  ),
  member procedure traverse_array(
    self in out nocopy ut_json_tree_details,
    a_json_piece json_element_t,
    a_parent_name varchar2 := null,
    a_hierarchy_level integer := 1,
    a_access_path varchar2 := '$'
  ),
  member procedure init(self in out nocopy ut_json_tree_details,a_json_doc in json_element_t, a_level_in integer := 0),
  constructor function ut_json_tree_details(
   self in out nocopy ut_json_tree_details, a_json_doc in json_element_t, a_level_in integer := 0
  ) return self as result
)
/
