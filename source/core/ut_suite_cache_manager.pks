create or replace noneditionable package ut_suite_cache_manager authid current_user is
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
   * Responsible for storing and retrieving suite data from cache
   *
   * The package runs with invoker rights. It accesses the suite cache tables of the framework owner
   * through the code based access control role <framework owner>_cbac_modify_objects_role granted to the package,
   * so all references to framework objects in SQL statements are qualified with the framework owner.
   * The owner is filled in by the SQL*Plus substitution variable ut3_owner when the package body is installed by install.sql.
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

  function get_schema_paths(a_paths in ut_varchar2_list) return ut_path_items;

  /*
  * Retrieves suite items matching the paths from cache, with logical suites added for suitepaths without a package.
  * Returns only items of packages the invoking user can access, unless a_skip_access_check is true.
  * When a_tags is given, returns only items with a test matching the tag expression below them (or being one).
  * The rows are sorted bottom up: children before parents, by line number or, when a_random_seed is given, randomly.
  * Not to be used publicly. Used internally for building suites at runtime and suites info.
  */
  function get_suite_rows(
    a_schema_paths       ut_path_items,
    a_skip_access_check  boolean,
    a_tags               varchar2 := null,
    a_random_seed        positive := null
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
 
end ut_suite_cache_manager;
/
