create table ut_annotation_cache_info (
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
  cache_id        number(20,0)  not null,
  object_owner    varchar2(250) not null,
  object_name     varchar2(250) not null,
  object_type     varchar2(250) not null,
  parse_time      timestamp     not null,
  constraint ut_annotation_cache_info_pk primary key(cache_id) using index,
  constraint ut_annotation_cache_info_uk unique (object_owner, object_type, object_name) using index,
  constraint ut_annotation_cache_info_fk foreign key(object_owner, object_type) references ut_annotation_cache_schema(object_owner, object_type) on delete cascade
) organization index;

