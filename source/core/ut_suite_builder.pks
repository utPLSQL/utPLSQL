create or replace package ut_suite_builder authid current_user is
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
   * Responsible for converting annotations into unit test suites
   */

  type tt_schema_suites is table of ut_logical_suite index by varchar2(4000 char);
  type t_object_suite_path is table of varchar2(4000) index by varchar2(4000 char);

  type t_schema_suites_info is record (
    schema_suites tt_schema_suites,
    suite_paths   t_object_suite_path
  );

  /**
   * Builds set of hierarchical suites for a given schema
   *
   * @param a_owner_name name of the schema to builds suites for
   * @return list of suites organized into hierarchy
   *
   */
  function build_schema_suites(a_owner_name varchar2) return t_schema_suites_info;

  /**
   * Builds set of hierarchical suites for given annotations
   *
   * @param a_annotated_objects cursor returning ut_annotated_object type
   * @return list of suites organized into hierarchy
   *
   */
  function build_suites(a_annotated_objects sys_refcursor) return t_schema_suites_info;

end ut_suite_builder;
/
