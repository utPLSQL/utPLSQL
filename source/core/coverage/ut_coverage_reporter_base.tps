create or replace type ut_coverage_reporter_base under ut_output_reporter_base(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

  overriding final member procedure before_calling_run(self in out nocopy ut_coverage_reporter_base, a_run ut_run),
  overriding final member procedure before_calling_before_all(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_before_all (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),

  overriding final member procedure before_calling_before_each(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_before_each (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),

  overriding final member procedure before_calling_before_test(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_before_test (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),

  overriding final member procedure before_calling_test_execute(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_test_execute (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),

  overriding final member procedure before_calling_after_test(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_after_test (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),

  overriding final member procedure before_calling_after_each(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_after_each (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),

  overriding final member procedure before_calling_after_all(self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable),
  overriding final member procedure after_calling_after_all (self in out nocopy ut_coverage_reporter_base, a_executable in ut_executable)

)
not final not instantiable
/
