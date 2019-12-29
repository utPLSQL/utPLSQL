create type ut_suite_cache_row as object (
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
  id number(22,0),
  self_type varchar2(250 byte),
  path varchar2(1000 byte),
  object_owner varchar2(250 byte),
  object_name varchar2(250 byte),
  name varchar2(250 byte),
  line_no number,
  parse_time timestamp (6),
  description varchar2(4000 byte),
  rollback_type number,
  disabled_flag number,
  warnings ut_varchar2_rows,
  before_all_list ut_executables,
  after_all_list ut_executables,
  before_each_list ut_executables,
  before_test_list ut_executables,
  after_each_list ut_executables,
  after_test_list ut_executables,
  expected_error_codes ut_varchar2_rows,
  tags ut_varchar2_rows,
  item ut_executable_test
)
/