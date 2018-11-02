create or replace type ut_suite_contexts as table of ut_suite_context
/
create or replace type ut_tests as table of ut_test
/

create table ut_suite_cache (
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project
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
  self_type,
  path,
  object_owner,
  object_name,
  name,
  line_no,
  parse_time,
  description,
  rollback_type,
  disabled_flag,
  warnings,
  before_all_list,
  after_all_list,
  before_each_list,
  before_test_list,
  after_each_list,
  after_test_list,
  expected_error_codes,
  item
)
  nested table warnings store as ut_suite_cache_warnings
  nested table before_all_list store as ut_suite_cache_before_all
  nested table after_all_list store as ut_suite_cache_after_all
  nested table before_each_list store as ut_suite_cache_before_each
  nested table after_each_list store as ut_suite_cache_after_each
  nested table before_test_list store as ut_suite_cache_before_test
  nested table after_test_list store as ut_suite_cache_after_test
  nested table expected_error_codes store as ut_suite_cache_trhows
  as
    select
           c.self_type,
           c.path,
           c.object_owner,
           c.object_name,
           c.name,
           c.line_no,
           c.parse_time,
           c.description,
           c.rollback_type,
           c.disabled_flag,
           c.warnings,
           c.before_all_list,
           c.after_all_list,
           t.before_each_list,
           t.before_test_list,
           t.after_each_list,
           t.after_test_list,
           t.expected_error_codes,
           t.item
    from table(ut_suite_contexts(ut_suite_context(user,'package_name','ctx_name',1))) c
           cross join table(ut_tests(ut_test(user,'package_name','test_name',1))) t
    where rownum < 0
/

alter table ut_suite_cache modify (object_owner not null, path not null, self_type not null, object_name not null, name not null, parse_time not null)
/
alter table ut_suite_cache add constraint ut_suite_cache_pk primary key (object_owner, path)
/
create index ut_suite_cache_nu1 on ut_suite_cache(object_owner, object_name, parse_time desc)
/
alter table ut_suite_cache add constraint ut_suite_cache_schema_fk foreign key (object_owner) references ut_suite_cache_schema(object_owner)
/

drop type ut_tests
/

drop type ut_suite_contexts
/
