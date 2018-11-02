create or replace type ut_logical_suite under ut_suite_item (
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
  * The list of items (suites/sub-suites/contexts/tests) to be invoked as part of this suite
  */
  items        ut_suite_items,

  constructor function ut_logical_suite(
    self in out nocopy ut_logical_suite, a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_path varchar2
  ) return self as result,
  member function is_valid(self in out nocopy ut_logical_suite) return boolean,
  overriding member procedure add_item(
    self in out nocopy ut_logical_suite,
    a_item ut_suite_item,
    a_expected_level integer := 1,
    a_current_level integer :=1
  ),
  overriding member procedure mark_as_skipped(self in out nocopy ut_logical_suite),
  overriding member procedure set_rollback_type(self in out nocopy ut_logical_suite, a_rollback_type integer),
  overriding member function  do_execute(self in out nocopy ut_logical_suite) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_logical_suite),
  overriding member procedure mark_as_errored(self in out nocopy ut_logical_suite, a_error_stack_trace varchar2),
  overriding member function get_error_stack_traces return ut_varchar2_list,
  overriding member function get_serveroutputs return clob,
  overriding member function get_transaction_invalidators return ut_varchar2_list
) not final
/
