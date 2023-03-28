create or replace package ut_suite_cache_manager authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
   * Responsible for storing and retrieving suite data from cache
   */

  /*
  * Saves suite items for individual package in suite cache
  */
  procedure save_object_cache(
    a_object_owner varchar2,
    a_object_name  varchar2,
    a_parse_time   timestamp,
    a_suite_items ut_suite_items
  );

  /*
  * Returns time when schema was last saved in cache
  */
  function get_schema_parse_time(a_schema_name varchar2) return timestamp result_cache;

  /*
  * Removes packages that are no longer annotated from cache
  */
  procedure remove_missing_objs_from_cache(a_schema_name varchar2);

  /*
  *  We will sort a suites in hierarchical structure.
  *  Sorting from bottom to top so when we consolidate
  *  we will go in proper order.
  */
  procedure sort_and_randomize_tests(
    a_suite_rows in out ut_suite_cache_rows,
    a_random_seed  positive := null);

  /*
  * Retrieves suite items data from cache.
  * Returned data is not filtered by user access rights.
  * Not to be used publicly. Used internally for building suites at runtime.
  */
  function get_cached_suite_rows(
    a_schema_paths     ut_path_items,
    a_random_seed      positive := null,
    a_tags             varchar2 := null
  ) return ut_suite_cache_rows;
  
  function get_schema_paths(a_paths in ut_varchar2_list) return ut_path_items;
  
  /*
  * Retrieves suite item info rows from cache.
  * Returned data is not filtered by user access rights.
  * Not to be used publicly. Used internally for building suites info.
  */
  function get_cached_suite_info(
    a_schema_paths     ut_path_items
  ) return ut_suite_cache_rows;
  
  function get_suite_items_info(
    a_suite_cache_items ut_suite_cache_rows
  ) return ut_suite_items_info;
  
  /*
  * Retrieves list of cached suite packages.
  * Returned data is not filtered by user access rights.
  * Not to be used publicly. Used internally.
  */
  function get_cached_packages(
    a_schema_names ut_varchar2_rows
  ) return ut_object_names;

  /*
  * Returns true if given suite item exists in cache.
  * Returned data is not filtered by user access rights.
  * Not to be used publicly. Used internally.
  */
  function suite_item_exists(
    a_owner_name     varchar2,
    a_package_name   varchar2,
    a_procedure_name varchar2
  ) return boolean;


function create_where_filter(a_tags varchar2
  ) return varchar2;
end ut_suite_cache_manager;
/
