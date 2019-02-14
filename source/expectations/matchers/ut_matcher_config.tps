create or replace type ut_matcher_config authid current_user as object(
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

  /**
  * Flag to force cursor comparision into ordered mode
  */
  columns_are_unordered_flag number(1,0),

  /**
   * Flag indicating that order of elements is to be ignored
   */
  is_unordered   number(1,0),

  /**
   * Flag determining how to react to null values
   */
  nulls_are_equal_flag number(1,0),

  /**
   * Holds (list of columns/attributes) to exclude when comparing compound types
   */
  exclude_list   ut_matcher_config_items,

  /**
   * Holds (list of columns/attributes) to incude when comparing compound types
   */
  include_list   ut_matcher_config_items,

  /**
   * Holds list of columns to be used as a join PK on sys_refcursor comparision
   */
  join_by_list ut_matcher_config_items,

  constructor function ut_matcher_config(self in out nocopy ut_matcher_config, a_nulls_are_equal in boolean := null) return self as result,
  member procedure nulls_are_equal(self in out nocopy ut_matcher_config),
  member function nulls_are_equal return boolean,
  member procedure include(self in out nocopy ut_matcher_config, a_include varchar2),
  member procedure include(self in out nocopy ut_matcher_config, a_include ut_varchar2_list),
  member function  include return ut_varchar2_list,
  member procedure exclude(self in out nocopy ut_matcher_config, a_exclude varchar2),
  member procedure exclude(self in out nocopy ut_matcher_config, a_exclude ut_varchar2_list),
  member function  exclude return ut_varchar2_list,
  member procedure join_by(self in out nocopy ut_matcher_config, a_join_by varchar2),
  member procedure join_by(self in out nocopy ut_matcher_config, a_join_by ut_varchar2_list),
  member function  join_by return ut_varchar2_list,
  member procedure unordered_columns(self in out nocopy ut_matcher_config),
  member function ordered_columns return boolean,
  member procedure unordered(self in out nocopy ut_matcher_config),
  member function unordered return boolean
)
/
