create or replace type ut_data_value_anydata under ut_data_value_refcursor(
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
  
  overriding member function get_object_info return varchar2,
  member function get_extract_path(a_data_value anydata) return varchar2,
  member function get_cursor_sql_from_anydata(a_data_value anydata) return varchar2,
  member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata),
  member function get_instance(a_data_value anydata) return varchar2,
  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result,
  overriding member function compare_implementation(
    a_other ut_data_value,
    a_match_options ut_matcher_options,
    a_inclusion_compare boolean := false,
    a_is_negated boolean := false
  ) return integer,
  overriding member function is_empty return boolean
)
/
