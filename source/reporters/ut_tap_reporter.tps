create or replace type ut_tap_reporter under ut_documentation_reporter(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

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

  constructor function ut_tap_reporter(self in out nocopy ut_tap_reporter) return self as result,
  member procedure print_comment(self in out nocopy ut_tap_reporter, a_comment clob),
  member function escape_special_chars(self in out nocopy ut_tap_reporter, a_string_to_escape clob) return clob,
  overriding member procedure before_calling_suite(self in out nocopy ut_tap_reporter, a_suite ut_logical_suite),

  overriding member procedure after_calling_test(self in out nocopy ut_tap_reporter, a_test ut_test),

  overriding member procedure after_calling_before_all (self in out nocopy ut_tap_reporter, a_executable in ut_executable),
  overriding member procedure after_calling_after_all (self in out nocopy ut_tap_reporter, a_executable in ut_executable),
  overriding member procedure before_calling_run(self in out nocopy ut_tap_reporter, a_run in ut_run),
  overriding member procedure after_calling_suite(self in out nocopy ut_tap_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_run(self in out nocopy ut_tap_reporter, a_run in ut_run)

)
not final
/
