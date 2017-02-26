create or replace type ut_logical_suite under ut_suite_item (
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

  /**
  * The list of items (suites/sub-suites/contexts/tests) to be invoked as part of this suite
  */
  items        ut_suite_items,

  constructor function ut_logical_suite(
    self in out nocopy ut_logical_suite,a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_description varchar2 := null, a_path varchar2
  ) return self as result,
  member function is_valid return boolean,
  /**
  * Finds the item in the suite by it's name and returns the item index
  */
  member function item_index(a_name varchar2) return pls_integer,
  member procedure add_item(self in out nocopy ut_logical_suite, a_item ut_suite_item),
  overriding member function  do_execute(self in out nocopy ut_logical_suite, a_listener in out nocopy ut_event_listener_base) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_logical_suite),
  overriding member procedure fail(self in out nocopy ut_logical_suite, a_listener in out nocopy ut_event_listener_base, a_failure_msg varchar2)
) not final
/
