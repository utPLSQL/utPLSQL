create or replace type ut_compound_data_value force under ut_data_value(
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
  
  /**
  * Holds name for the type of compound
  */
  compound_type varchar2(50),
  
  overriding member function get_object_info return varchar2,
  overriding member function is_null return boolean,
  overriding member function is_diffable return boolean,
  overriding member function to_string return varchar2,
  overriding member function is_multi_line return boolean
) not final not instantiable
/
