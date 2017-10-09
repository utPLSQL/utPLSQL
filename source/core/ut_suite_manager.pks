create or replace package ut_suite_manager authid current_user is
  /*
  utPLSQL - Version X.X.X.X
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

  --builds individual suites from a cursor of objects and their annotations
  function build_suites(a_cursor sys_refcursor) return ut_suite_items pipelined;

  --for testing purposes only
  function config_package(a_owner_name varchar2, a_object_name varchar2) return ut_logical_suite;

  function get_schema_ut_packages(a_schema_names ut_varchar2_rows) return ut_object_names;

  --INTERNAL USE
  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items;

end ut_suite_manager;
/
