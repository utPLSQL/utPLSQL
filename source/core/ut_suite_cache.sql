create table ut_suite_cache 
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
  of ut_suite_cache_row
  nested table warnings store as ut_suite_cache_warnings
  nested table before_all_list store as ut_suite_cache_before_all
  nested table after_all_list store as ut_suite_cache_after_all
  nested table before_each_list store as ut_suite_cache_before_each
  nested table after_each_list store as ut_suite_cache_after_each
  nested table before_test_list store as ut_suite_cache_before_test
  nested table after_test_list store as ut_suite_cache_after_test
  nested table expected_error_codes store as ut_suite_cache_throws
  nested table tags store as ut_suite_cache_tags return as locator
/

alter table ut_suite_cache modify (object_owner not null, path not null, self_type not null, object_name not null, name not null, parse_time not null)
/
alter table ut_suite_cache add constraint ut_suite_cache_pk primary key (id)
/
alter table ut_suite_cache add constraint ut_suite_cache_uk1 unique (object_owner, path)
/
alter table ut_suite_cache add constraint ut_suite_cache_uk2 unique (object_owner, object_name, line_no)
/

alter table ut_suite_cache add constraint ut_suite_cache_schema_fk foreign key (object_owner, object_name)
references ut_suite_cache_package(object_owner, object_name) on delete cascade
/
