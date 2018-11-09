create or replace type ut_data_value_refcursor under ut_compound_data_value(
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
   * Holds information about ref cursor to be processed by expectation
   */


  /**
   * Determines if the cursor is null
   */
  is_cursor_null  integer,
  
  /**
  * hold information if the cursor contains collection object
  */
  contain_collection number(1,0),
  
  /**
  * Holds information about column names and column data-types
  */
  columns_info       xmltype,
  
  /**
  * Holds more detailed information regarding the pk joins
  */
  key_info xmltype,
  
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result,
  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor),
  overriding member function to_string return varchar2,
  overriding member function diff( a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2, a_unordered boolean := false ) return varchar2,
  overriding member function compare_implementation(a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2, 
                                                    a_unordered boolean, a_inclusion_compare boolean := false, a_is_negated boolean := false) return integer,
  overriding member function is_empty return boolean
)
/
