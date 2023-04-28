create or replace package ut_suite_tag_filter authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2023 utPLSQL Project

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
   * Package that will filter suites by tags
   *
   */

  /*
  * Return table of tokens character by character
  */   
  function tokenize_tags_string(a_tags in varchar2) return ut_varchar2_list;

  /*
  * Function that uses Dijkstra algorithm to parse mathematical and logical expression
  * and return a list of elements in Reverse Polish Notation ( postfix )
  * As part of execution it will validate expression.
  */
  function shunt_logical_expression(a_tags in ut_varchar2_list) return ut_varchar2_list;

  /*
  * Function that converts postfix notation into infix and creating a string of sql filter 
  * that checking a tags collections for tags according to posted logic.
  */  
  function conv_postfix_to_infix_sql(a_postfix_exp in ut_varchar2_list,a_tags_column_name in varchar2)
    return varchar2;  
  
  /*
  * Generates a part where clause sql 
  */  
  function create_where_filter(a_tags varchar2) 
    return varchar2;

  function apply(
    a_unfiltered_rows  ut_suite_cache_rows,
    a_tags             varchar2 := null
  ) return ut_suite_cache_rows;

end ut_suite_tag_filter;
/
