create or replace type ut_coveralls_reporter under ut_coverage_reporter_base(
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

  /**
  * Builds a coverage XML report that follows rules described in
  * https://docs.sonarqube.org/display/SONAR/Generic+Test+Data
  */
  constructor function ut_coveralls_reporter(
    self in out nocopy ut_coveralls_reporter,
    a_schema_names ut_varchar2_list := null,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result,

  constructor function ut_coveralls_reporter(
    self in out nocopy ut_coveralls_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_regex_pattern varchar2,
    a_object_owner_subexpression positive,
    a_object_name_subexpression positive,
    a_object_type_subexpression positive,
    a_file_to_object_type_mapping ut_key_value_pairs,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result,

  constructor function ut_coveralls_reporter(
    self in out nocopy ut_coveralls_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result,

  constructor function ut_coveralls_reporter(
    self in out nocopy ut_coveralls_reporter,
    a_file_mappings       ut_coverage_file_mappings,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result,

  overriding member procedure after_calling_run(self in out nocopy ut_coveralls_reporter, a_run in ut_run)
)
/
