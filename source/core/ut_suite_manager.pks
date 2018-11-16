create or replace package ut_suite_manager authid current_user is
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
   * Resposible for building hierarhy of sutes from individual suites created by suite_builder
   */

  /**
   * @private
   *
   * Returns a list of Unit Test packages that exist in a given database schema
   *
   * @param a_schema_names list of schemas to return the information for
   * @return array containing unit test schema and object names
   */
  function get_schema_ut_packages(a_schema_names ut_varchar2_rows) return ut_object_names;

  /**
   * Builds a hierarchical suites based on given suite-paths
   *
   * @param a_paths list of suite-paths or procedure names or package names or schema names
   * @return array containing root suites-ready to be executed
   *
   */
  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items;

  /**
   * Builds a hierarchical suites based on given suite-paths
   *
   * @param a_paths   list of suite-paths or procedure names or package names or schema names
   * @param a_suites  returned array containing root suites-ready to be executed
   *
   */
  procedure configure_execution_by_path(a_paths in ut_varchar2_list, a_suites out nocopy ut_suite_items);

  /**
   * Cleanup paths by removing leading/trailing whitespace and making paths lowercase
   * Get list of schema names from execution paths.
   */
  function get_schema_names(a_paths ut_varchar2_list) return ut_varchar2_rows;


  /**
  * Constructs a list of suites based on the list of annotations passed
  * the suites are stored in cache
  */
  function build_suites_from_annotations(
    a_owner_name        varchar2,
    a_annotated_objects sys_refcursor,
    a_path              varchar2 := null,
    a_object_name       varchar2 := null,
    a_procedure_name    varchar2 := null,
    a_skip_all_objects  boolean := false
  ) return ut_suite_items;


  /**
  * Returns a ref cursor containing information about unit test suites and the tests contained in them
  *
  * @param   a_owner        owner of unit tests to retrieve
  * @return  ut_suite_items_info table of objects
  */
  function get_suites_info(a_owner_name varchar2, a_package_name varchar2) return sys_refcursor;


end ut_suite_manager;
/
