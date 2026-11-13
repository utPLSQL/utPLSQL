create or replace noneditionable package ut_suite_cache_macros authid definer as
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

  /*
   * SQL macros for ut_suite_cache_manager.
   *
   * A package containing SQL macros cannot be an invoker rights package, so the macros are kept apart from ut_suite_cache_manager.
   * A macro only returns SQL text, which is expanded into the calling SQL statement.
   * A macro body sees the values of literal arguments only, so the returned text does not depend on argument values.
   */

  /**
   * Table SQL macro matching suite items with run paths: the single definition of which items a run path selects.
   * Returns one row (path_id, object_owner, path) for every pair of a path and an item it selects:
   * - schema:                         all items of the schema
   * - schema.package[.*]:             all items of the package
   * - schema.package.procedure:       the items named like the procedure
   * - schema:suite.path:              the item at the suitepath and all items below it
   * - schema:suite*.path:             the items whose path starts with a match of the suitepath pattern
   * Package and procedure names may contain wildcards (*). Parents of the selected items are not returned.
   *
   * @param a_items table or query with columns object_owner, object_name, name, path (as in ut_suite_cache), without collection columns
   * @param a_paths table or query with columns path_id and the columns of ut_path_item
   */
  function match_paths(a_items dbms_tf.table_t, a_paths dbms_tf.table_t) return varchar2 sql_macro;

end;
/
