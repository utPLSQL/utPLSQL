create or replace type ut_executable_test authid current_user under ut_executable (
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
  constructor function ut_executable_test( self in out nocopy ut_executable_test, a_context ut_suite_item, a_procedure_name varchar2, a_associated_event_name varchar2) return self as result,
  member procedure do_execute(self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base,
                              a_expected_error_codes in ut_varchar2_list := null),
  member function do_execute(self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base,
                              a_expected_error_codes in ut_varchar2_list := null) return boolean
) final;
