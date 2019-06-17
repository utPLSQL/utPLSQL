create table ut_annotation_cache (
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
  cache_id                      number(20,0)   not null,
  annotation_position           number(5,0)    not null,
  annotation_name               varchar2(1000) not null,
  annotation_text               varchar2(4000),
  subobject_name                varchar2(250),
  constraint ut_annotation_cache_pk primary key(cache_id, annotation_position),
  constraint ut_annotation_cache_fk foreign key(cache_id) references ut_annotation_cache_info(cache_id) on delete cascade
);

create index ut_annotation_cache_fk on ut_annotation_cache(cache_id);

