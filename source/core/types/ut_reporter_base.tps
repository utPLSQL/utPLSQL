create or replace type ut_reporter_base authid current_user as object(
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
  self_type    varchar2(250),
  reporter_id  raw(32),
  start_date   date,
  final member procedure init(self in out nocopy ut_reporter_base, a_self_type varchar2),

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter_base, a_run in ut_run),

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_before_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_each(self in out nocopy ut_reporter_base, a_suite in ut_test),
  member procedure after_calling_before_each (self in out nocopy ut_reporter_base, a_suite in ut_test),

  -- test hooks
  member procedure before_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_before_test(self in out nocopy ut_reporter_base, a_test in ut_test),
  member procedure after_calling_before_test (self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_test_execute(self in out nocopy ut_reporter_base, a_test in ut_test),
  member procedure after_calling_test_execute (self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_after_test(self in out nocopy ut_reporter_base, a_test in ut_test),
  member procedure after_calling_after_test (self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure after_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test),

  --suite hooks continued
  member procedure before_calling_after_each(self in out nocopy ut_reporter_base, a_suite in ut_test),
  member procedure after_calling_after_each (self in out nocopy ut_reporter_base, a_suite in ut_test),

  member procedure before_calling_after_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_after_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure after_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter_base, a_run in ut_run),
  not instantiable member procedure finalize(self in out nocopy ut_reporter_base)

)
not final not instantiable
/
