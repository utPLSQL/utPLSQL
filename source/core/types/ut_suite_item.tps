create or replace type ut_suite_item force under ut_event_item (
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
  * owner of the database object (package)
  */
  object_owner  varchar2(4000 byte),
  /**
  * name of the database object (package)
  */
  object_name   varchar2(4000 byte),
  /**
  * Name of the object (suite, sub-suite, test)
  */
  name          varchar2(4000 byte),
  /**
  * Description fo the suite item (as given by the annotation)
  */
  description   varchar2(4000 byte),

  /**
  * Full path of the invocation of the item (including the items name itself)
  */
  path          varchar2(4000 byte),
  /**
  * The type of the rollback behavior
  */
  rollback_type integer(1),
  /**
  * Indicates if the test is to be disabled by execution
  */
  disabled_flag integer(1),
  --execution result fields
  start_time    timestamp with time zone,
  end_time      timestamp with time zone,
  result        integer(1),
  warnings      ut_varchar2_list,
  results_count ut_results_counter,
  transaction_invalidators ut_varchar2_list,
  member procedure init(self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2),
  member procedure set_disabled_flag(self in out nocopy ut_suite_item, a_disabled_flag boolean),
  member function get_disabled_flag return boolean,
  not instantiable member procedure mark_as_skipped(self in out nocopy ut_suite_item),
  member procedure set_rollback_type(self in out nocopy ut_suite_item, a_rollback_type integer),
  member function get_rollback_type return integer,
  member function create_savepoint_if_needed return varchar2,
  member procedure rollback_to_savepoint(self in out nocopy ut_suite_item, a_savepoint varchar2),
  member function get_transaction_invalidators return ut_varchar2_list,
  member procedure add_transaction_invalidator(self in out nocopy ut_suite_item, a_object_name varchar2),
  /*
    Returns execution time in seconds (with miliseconds)
  */
  member function execution_time return number,

  not instantiable member function do_execute(self in out nocopy ut_suite_item) return boolean,
  final member procedure do_execute(self in out nocopy ut_suite_item),
  not instantiable member procedure calc_execution_result(self in out nocopy ut_suite_item),
  not instantiable member procedure mark_as_errored(self in out nocopy ut_suite_item, a_error_stack_trace varchar2),
  not instantiable member function get_error_stack_traces return ut_varchar2_list,
  not instantiable member function get_serveroutputs return clob,
  member procedure put_warning(self in out nocopy ut_suite_item, a_message varchar2)
)
not final not instantiable
/
