create or replace noneditionable package ut_suite_tag_filter authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  /**
   * Package that evaluates tag expressions against the tags of suite items.
   * is_matching is called from SQL by ut_suite_cache_manager.get_suite_rows to filter suites by tags.
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
  * Returns the tag expression without spaces and tabs.
  * Tags cannot contain whitespace, so it only separates the tokens of an expression.
  * An expression made only of spaces and tabs becomes null, which is no tag filter.
  */
  function remove_whitespace(a_tag_expression varchar2) return varchar2;

  /*
  * Returns 1 when the tags match the tag expression, 0 otherwise.
  * An empty tag expression (see remove_whitespace) matches any tags.
  * a_tags is a comma-separated list of tags (tags cannot contain commas), null for no tags.
  * Takes text, not a collection: Oracle caches results of a deterministic function called from SQL
  * only when all arguments are scalars, so items with the same tags are evaluated once per statement.
  * Raises ut_utils.gc_invalid_tag_expression for an invalid expression.
  */
  function is_matching(a_tags varchar2, a_tag_expression varchar2)
    return integer deterministic;

end ut_suite_tag_filter;
/
