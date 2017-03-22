create or replace type ut_suite_item force under ut_suite_item_base (
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

  results_count ut_results_counter,
  member procedure init(
    self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2,
    a_description varchar2, a_path varchar2, a_rollback_type integer, a_disabled_flag boolean),
  member procedure set_disabled_flag(self in out nocopy ut_suite_item, a_disabled_flag boolean),
  member function get_disabled_flag return boolean,
  member function create_savepoint_if_needed return varchar2,
  member procedure rollback_to_savepoint(self in ut_suite_item, a_savepoint varchar2),
  member function execution_time return number,

  not instantiable member function  do_execute(self in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) return boolean,
  final member procedure do_execute(self in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base),
  not instantiable member procedure calc_execution_result(self in out nocopy ut_suite_item),
  not instantiable member procedure mark_as_errored(self in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base, a_error_stack_trace varchar2),
  not instantiable member function get_error_stack_traces return ut_varchar2_list,
  not instantiable member function get_serveroutputs return clob,
  member procedure put_warning(self in out nocopy ut_suite_item, a_message varchar2)
)
not final not instantiable
/
