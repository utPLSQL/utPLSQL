create or replace type ut_matcher_options authid current_user as object(
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

  /**
  * Flag indicating that columns order is to be ignored
  */
  columns_are_unordered_flag number(1,0),

  /**
   * Flag indicating that rows/items order is to be ignored
   */
  is_unordered   number(1,0),

  /**
   * Flag determining how to react to null values
   */
  nulls_are_equal_flag number(1,0),

  /**
   * Holds (list of columns/attributes) to exclude when comparing compound types
   */
  exclude   ut_matcher_options_items,

  /**
   * Holds (list of columns/attributes) to incude when comparing compound types
   */
  include   ut_matcher_options_items,

  /**
   * Holds list of columns to be used as a join PK on sys_refcursor comparision
   */
  join_by ut_matcher_options_items,

  constructor function ut_matcher_options(self in out nocopy ut_matcher_options, a_nulls_are_equal in boolean := null) return self as result,
  member procedure nulls_are_equal(self in out nocopy ut_matcher_options),
  member function nulls_are_equal return boolean,
  member procedure unordered_columns(self in out nocopy ut_matcher_options),
  member function ordered_columns return boolean,
  member procedure unordered(self in out nocopy ut_matcher_options),
  member function unordered return boolean
)
/
