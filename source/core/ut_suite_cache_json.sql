create table ut_suite_cache_json (
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
  object_owner varchar2(128) not null,
  object_name  varchar2(128) not null,
  content      clob  constraint ensure_json check (content IS JSON),
  constraint ut_suite_cache_json_schema_fk foreign key (object_owner, object_name)
    references ut_suite_cache_package(object_owner, object_name) on delete cascade
)
/
create index ut_suite_cache_json_nu1 on ut_suite_cache_json(object_owner, object_name)
/

--TODO remove when not needed anymore
create table test_json_cache_data(
  rn integer,
  obj clob constraint test_json_cache_data_json check (obj IS JSON)
)
/