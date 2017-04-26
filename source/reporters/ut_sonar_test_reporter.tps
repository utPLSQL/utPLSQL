create or replace type ut_sonar_test_reporter under ut_reporter_base(
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
  file_mappings ut_coverage_file_mappings,

  constructor function ut_sonar_test_reporter(
    self in out nocopy ut_sonar_test_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_regex_pattern varchar2,
    a_object_owner_subexpression positive,
    a_object_name_subexpression positive,
    a_object_type_subexpression positive,
    a_file_to_object_type_mapping ut_key_value_pairs
  ) return self as result,

  constructor function ut_sonar_test_reporter(
    self in out nocopy ut_sonar_test_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list
  ) return self as result,

  constructor function ut_sonar_test_reporter(
    self in out nocopy ut_sonar_test_reporter,
    a_file_mappings       ut_coverage_file_mappings
  ) return self as result,


  overriding member procedure before_calling_run(self in out nocopy ut_sonar_test_reporter, a_run in ut_run),
  overriding member procedure before_calling_suite(self in out nocopy ut_sonar_test_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_test(self in out nocopy ut_sonar_test_reporter, a_test ut_test),
  overriding member procedure after_calling_suite(self in out nocopy ut_sonar_test_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_run(self in out nocopy ut_sonar_test_reporter, a_run in ut_run)
)
not final
/
