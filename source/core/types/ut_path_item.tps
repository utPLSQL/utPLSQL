create or replace type ut_path_item as object (
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
  schema_name     varchar2(4000),
  object_name     varchar2(250),
  procedure_name  varchar2(250),
  suite_path      varchar2(4000),
  originated_path varchar2(4000),
  constructor function ut_path_item(self in out nocopy ut_path_item, schema_name varchar2, object_name varchar2,procedure_name varchar2, originated_path varchar2) return self as result,
  constructor function ut_path_item(self in out nocopy ut_path_item, schema_name varchar2, suite_path varchar2, originated_path varchar2) return self as result,
  constructor function ut_path_item(self in out nocopy ut_path_item, schema_name varchar2, object_name varchar2,procedure_name varchar2,suite_path varchar2, originated_path varchar2) return self as result
)
/