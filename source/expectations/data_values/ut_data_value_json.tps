create or replace type ut_data_value_json under ut_compound_data_value(
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
  data_value     clob,
  json_tree      ut_json_tree_details,
  member procedure init (self in out nocopy ut_data_value_json, a_value json_element_t),
  constructor function ut_data_value_json(self in out nocopy ut_data_value_json, a_value json_element_t) return self as result,
  overriding member function is_null return boolean,
  overriding member function is_empty return boolean,
  overriding member function to_string return varchar2,
  overriding member function diff( a_other ut_data_value, a_match_options ut_matcher_options ) return varchar2,
  overriding member function compare_implementation(a_other ut_data_value) return integer,
  member function compare_implementation(a_other ut_data_value,a_match_options ut_matcher_options) return integer,
  member function get_elements_count return integer,
  member function get_json_count_info return varchar2,
  overriding member function get_object_info return varchar2
)
/
