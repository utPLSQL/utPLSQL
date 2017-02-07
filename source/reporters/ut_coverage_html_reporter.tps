create or replace type ut_coverage_html_reporter force under ut_coverage_reporter_base(
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
  coverage_id integer,
  schema_names ut_varchar2_list,
  project_name varchar2(4000),
  constructor function ut_coverage_html_reporter(self in out nocopy ut_coverage_html_reporter, a_project_name varchar2 := null, a_schema_names ut_varchar2_list := null) return self as result,
  overriding member procedure before_calling_run(self in out nocopy ut_coverage_html_reporter, a_run ut_run),
  overriding member procedure after_calling_run(self in out nocopy ut_coverage_html_reporter, a_run in ut_run)
)
/
