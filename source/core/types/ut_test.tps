create or replace type ut_test under ut_suite_item (
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
  * The procedure to be invoked before invoking the test
  * Procedure exists within the same package as the test itself
  */
  before_test ut_executable,
  /**
  * The Test procedure to be executed
  */
  item        ut_executable,
  /**
  * The procedure to be invoked after invoking the test
  * Procedure exists within the same package as the test itself
  */
  after_test  ut_executable,
  /**
  * The list of assert results as well as database errors encountered while invoking
  * The test procedure and the before_test/after_test blocks
  */
  results     ut_assert_results,
  constructor function ut_test(
    self in out nocopy ut_test, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2, a_description varchar2 := null,
    a_path varchar2 := null, a_rollback_type integer := null, a_ignore_flag boolean := false, a_before_test_proc_name varchar2 := null, a_after_test_proc_name varchar2 := null
  ) return self as result,
  member function is_valid return boolean,
  overriding member function do_execute(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_test),
  overriding member procedure fail(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base, a_failure_msg varchar2)
)
/
