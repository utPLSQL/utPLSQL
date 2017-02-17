create or replace type ut_reporter_base force authid current_user as object(
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
  warnings     ut_varchar2_list,
  final member procedure init(self in out nocopy ut_reporter_base, a_self_type varchar2),
  final member function get_reporter_id(self in out nocopy ut_reporter_base) return raw,

  member procedure print_text(self in out nocopy ut_reporter_base, a_text varchar2),

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter_base, a_run in ut_run),

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_before_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_each(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_before_each (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

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
  member procedure before_calling_after_each(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_after_each (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_after_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_after_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure after_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter_base, a_run in ut_run),
  
  member procedure save_warning(self in out nocopy ut_reporter_base, a_item ut_suite_item_base, a_message varchar2)

)
not final not instantiable
/
