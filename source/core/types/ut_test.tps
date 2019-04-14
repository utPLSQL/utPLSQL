create or replace type ut_test force under ut_suite_item (
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
  /*
  * Procedures to be invoked before invoking the test and before_test_list procedures.
  */
  before_each_list ut_executables,
  /**
  * Procedures to be invoked before invoking the test
  */
  before_test_list ut_executables,
  /**
  * The Test procedure to be executed
  */
  item        ut_executable_test,
  /**
  * Procedures to be invoked after invoking the test
  */
  after_test_list  ut_executables,
  /*
  * Procedures to be invoked after invoking the test and after_test_list procedures.
  */
  after_each_list ut_executables,
  /**
  * The list of all expectations results as well as database errors encountered while invoking
  * the test procedure and the before_test/after_test blocks
  */
  all_expectations    ut_expectation_results,

  /**
  * The list of failed expectations results as well as database errors encountered while invoking
  * the test procedure and the before_test/after_test blocks
  */
  failed_expectations ut_expectation_results,
  /**
  * Holds information about error stacktrace from parent execution (suite)
  * Will get populated on exceptions in before-all calls
  */
  parent_error_stack_trace varchar2(4000),
  /**
  *Holds the expected error codes list when the user use the annotation throws
  */
  expected_error_codes  ut_integer_list,
  /**
  * Hold list of tags assign to test
  */
  test_tags ut_varchar2_rows,
  constructor function ut_test(
    self in out nocopy ut_test, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2,
    a_line_no integer, a_expected_error_codes ut_integer_list := null, a_test_tags ut_varchar2_rows := null
  ) return self as result,
  overriding member procedure mark_as_skipped(self in out nocopy ut_test),
  overriding member function do_execute(self in out nocopy ut_test) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_test),
  overriding member procedure mark_as_errored(self in out nocopy ut_test, a_error_stack_trace varchar2),
  overriding member function get_error_stack_traces(self ut_test) return ut_varchar2_list,
  overriding member function get_serveroutputs return clob
)
/
