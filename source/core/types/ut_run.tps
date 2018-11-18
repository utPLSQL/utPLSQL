create or replace type ut_run under ut_suite_item (
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
  * The list of items (suites) to be invoked as part of this run
  */
  project_name                   varchar2(4000),
  items                          ut_suite_items,
  run_paths                      ut_varchar2_list,
  coverage_options               ut_coverage_options,
  test_file_mappings             ut_file_mappings,
  client_character_set           varchar2(100),
  constructor function ut_run(
    self in out nocopy ut_run,
    a_items                 ut_suite_items,
    a_run_paths             ut_varchar2_list := null,
    a_schema_names          ut_varchar2_rows := null,
    a_exclude_objects       ut_object_names := null,
    a_include_objects       ut_object_names := null,
    a_project_file_mappings ut_file_mappings := null,
    a_test_file_mappings    ut_file_mappings := null,
    a_client_character_set  varchar2 := null
  ) return self as result,
  overriding member procedure mark_as_skipped(self in out nocopy ut_run),
  overriding member function  do_execute(self in out nocopy ut_run) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_run),
  overriding member procedure mark_as_errored(self in out nocopy ut_run, a_error_stack_trace varchar2),
  overriding member function get_error_stack_traces return ut_varchar2_list,
  overriding member function get_serveroutputs return clob
)
/
