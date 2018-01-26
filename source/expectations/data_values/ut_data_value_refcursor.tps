create or replace type ut_data_value_refcursor under ut_data_value(
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
  /**
   * Holds information about ref cursor to be processed by expectation
   */


  /**
   * Determines if the cursor is null
   */
  is_cursor_null  integer,

  /**
   * Holds the number of rows from the cursor
   */
  row_count       integer,

  /**
   * Holds unique id for retrieving the cursor data from ut_data_set_tmp temp table
   */
  data_set_guid  raw(16),

  /**
   * Holds xpath (list of columns) to exclude when comparing cursors
   */
  exclude_xpath   varchar2(32767),

  /**
   * Holds xpath (list of columns) to include when comparing cursors
   */
  include_xpath   varchar2(32767),

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude varchar2 := null, a_include varchar2 := null) return self as result,
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude ut_varchar2_list) return self as result,
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude ut_varchar2_list := null, a_include ut_varchar2_list) return self as result,
  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor),
  overriding member function is_null return boolean,
  overriding member function is_diffable return boolean,
  overriding member function get_object_info return varchar2,
  overriding member function to_string return varchar2,
  overriding member function diff( a_other ut_data_value ) return varchar2,
  member function is_empty return boolean,
  overriding member function is_multi_line return boolean,
  overriding member function compare_implementation(a_other ut_data_value) return integer
)
/
