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
  /*
    class: ut_data_value_refcursor

    Holds information about ref cursor to be processed by expectation
  */


  /*
    var: is_cursor_null
    Determines if the cursor is null
  */
  is_cursor_null  integer,

  /*
    var: row_count
    Holds the number of rows from the cursor
  */
  row_count       integer,

  /*
    var: data_value
    Holds unique id for retrieving the cursor data from ut_cursor_data temp table
  */
  data_value raw(16),

  /*
    var: exclude_xpath
    Holds xpath (list of columns) to exclude when comparing cursor
  */
  exclude_xpath   varchar2(32767),

  /*
    function: ut_data_value_refcursor

    constructor function that builds object from passed refcursor
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result,

  /*
    function: ut_data_value_refcursor

    constructor function that builds object from passed ref cursor and comma separated exclude column names
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude varchar2 ) return self as result,

  /*
    function: ut_data_value_refcursor

    constructor function that builds object from passed ref cursor and the exclude column names list
  */
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude ut_varchar2_list ) return self as result,
  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor),
  overriding member function is_null return boolean,
  overriding member function to_string return varchar2,
  member function is_empty return boolean,
  overriding member function is_multi_line return boolean,
  overriding member function compare_implementation(a_other ut_data_value) return integer
)
/
