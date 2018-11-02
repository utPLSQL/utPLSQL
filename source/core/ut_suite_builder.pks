create or replace package ut_suite_builder authid current_user is
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
   * Responsible for converting annotations into unit test suites
   */

  /**
   * Builds set of hierarchical suites for a given schema
   *
   * @param a_owner_name  name of the schema to builds suite for
   * @param a_path        suite path to build suite for  (optional)
   * @param a_object_name object name to build suite for (optional)
   * @param a_object_name procedure name to build suite for (optional)
   * @return list of suites organized into hierarchy
   *
   */
  function build_schema_suites(
    a_owner_name     varchar2,
    a_path           varchar2 := null,
    a_object_name    varchar2 := null,
    a_procedure_name varchar2 := null
  ) return ut_suite_items;

  function build_suites_from_annotations(
    a_owner_name        varchar2,
    a_annotated_objects sys_refcursor,
    a_path              varchar2 := null,
    a_object_name       varchar2 := null,
    a_procedure_name    varchar2 := null
  ) return ut_suite_items;

end ut_suite_builder;
/
