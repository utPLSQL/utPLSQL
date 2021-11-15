create or replace type ut_session_info under ut_event_listener (
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  module             varchar2(4000),
  action             varchar2(4000),
  client_info        varchar2(4000),
  constructor function ut_session_info(self in out nocopy ut_session_info) return self as result,

  member procedure before_calling_run(self in out nocopy ut_session_info, a_run in ut_run),
  member procedure after_calling_run (self in out nocopy ut_session_info, a_run in ut_run),

  member procedure before_calling_suite(self in out nocopy ut_session_info, a_suite in ut_logical_suite),
  member procedure after_calling_suite(self in out nocopy ut_session_info, a_suite in ut_logical_suite),

  member procedure before_calling_executable(self in out nocopy ut_session_info, a_executable in ut_executable),
  member procedure after_calling_executable (self in out nocopy ut_session_info, a_executable in ut_executable),

  member procedure before_calling_test(self in out nocopy ut_session_info, a_test in ut_test),
  member procedure after_calling_test (self in out nocopy ut_session_info, a_test in ut_test),

  member procedure on_finalize(self in out nocopy ut_session_info, a_run in ut_run),

  /**
  * Returns the list of events that are supported by particular implementation of the reporter
  */
  overriding member function get_supported_events return ut_varchar2_list,

  /**
  * Delegates execution of event into individual reporting procedures
  */
  overriding member procedure on_event( self in out nocopy ut_session_info, a_event_name varchar2, a_event_item ut_event_item)

) final
/