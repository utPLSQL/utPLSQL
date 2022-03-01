create or replace type ut_coverage_options force as object (
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

  coverage_run_id  raw(32),
  schema_names     ut_varchar2_rows,
  exclude_objects  ut_object_names,
  include_objects  ut_object_names,
  file_mappings    ut_file_mappings,
  include_schema_expr varchar2(4000),
  include_object_expr varchar2(4000),
  exclude_schema_expr varchar2(4000),
  exclude_object_expr varchar2(4000),
  constructor function ut_coverage_options(
    self       in out nocopy ut_coverage_options,
    coverage_run_id          raw,
    schema_names             ut_varchar2_rows := null,
    exclude_objects          ut_varchar2_rows := null,
    include_objects          ut_varchar2_rows := null,
    file_mappings            ut_file_mappings := null,
    include_schema_expr varchar2 := null,
    include_object_expr varchar2 := null,
    exclude_schema_expr varchar2 := null,
    exclude_object_expr varchar2 := null
    ) return self as result
)
/
