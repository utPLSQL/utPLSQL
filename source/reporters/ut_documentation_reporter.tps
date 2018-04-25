create or replace type ut_documentation_reporter under ut_console_reporter_base(
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
  lvl                       integer,
  failed_test_running_count integer,
  constructor function ut_documentation_reporter(self in out nocopy ut_documentation_reporter) return self as result,
  member function tab(self in ut_documentation_reporter) return varchar2,

  overriding member procedure print_text(self in out nocopy ut_documentation_reporter, a_text varchar2),
  overriding member procedure before_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_test(self in out nocopy ut_documentation_reporter, a_test ut_test),
  overriding member procedure after_calling_after_all (self in out nocopy ut_documentation_reporter, a_executable in ut_executable),
  overriding member procedure after_calling_before_all (self in out nocopy ut_documentation_reporter, a_executable in ut_executable),
  overriding member procedure after_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_run(self in out nocopy ut_documentation_reporter, a_run in ut_run),

  overriding member function get_description return varchar2

)
not final
/
