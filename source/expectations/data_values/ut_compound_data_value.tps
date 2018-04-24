create or replace type ut_compound_data_value force under ut_data_value(
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
  is_data_null   integer,

  /**
   * Holds the number of elements in the compound data value (cursor/collection)
   */
  elements_count  integer,

  /**
   * Holds unique id for retrieving the data from ut_compound_data_tmp temp table
   */
  data_id  raw(16),

  overriding member function get_object_info return varchar2,
  overriding member function is_null return boolean,
  overriding member function is_diffable return boolean,
  member function is_empty return boolean,
  overriding member function to_string return varchar2,
  overriding member function is_multi_line return boolean,
  overriding member function compare_implementation(a_other ut_data_value) return integer,
  overriding member function diff( a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2, a_unordered boolean := false ) return varchar2,
  member function get_data_diff( a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_unordered boolean ) return clob,
  member function get_data_diff( a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2 ) return clob,
  member function compare_implementation(a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2) return integer,
  member function compare_implementation(a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2, a_unordered boolean ) return integer
) not final not instantiable
/
