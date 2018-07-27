create or replace type ut_reporter_base under ut_event_listener (
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
  id         raw(32),
  final member procedure init(self in out nocopy ut_reporter_base, a_self_type varchar2),
  member procedure set_reporter_id(self in out nocopy ut_reporter_base, a_reporter_id raw),
  member function  get_reporter_id return raw,
  member function  get_description return varchar2,

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter_base, a_run in ut_run),

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_all(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_before_all (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  member procedure before_calling_before_each(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_before_each (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  -- test hooks
  member procedure before_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_before_test(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_before_test (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  member procedure before_calling_test_execute(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_test_execute (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  member procedure before_calling_after_test(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_after_test (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  member procedure after_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test),

  --suite hooks continued
  member procedure before_calling_after_each(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_after_each (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  member procedure before_calling_after_all(self in out nocopy ut_reporter_base, a_executable in ut_executable),
  member procedure after_calling_after_all (self in out nocopy ut_reporter_base, a_executable in ut_executable),

  member procedure after_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter_base, a_run in ut_run),

  -- This method is executed when reporter is getting finalized
  -- it differs from after_calling_run, as it is getting called, even when the run fails
  -- This way, you may close all open outputs, files, connections etc. that need closing before the run finishes
  not instantiable member procedure on_finalize(self in out nocopy ut_reporter_base, a_run in ut_run),

  /**
  * Returns the list of events that are supported by particular implementation of the reporter
  */
  overriding member function get_supported_events return ut_varchar2_list,

  /**
  * Delegates execution of event into individual reporting procedures
  */
  overriding member procedure on_event( self in out nocopy ut_reporter_base, a_event_name varchar2, a_event_item ut_event_item)

)
not final not instantiable
/
