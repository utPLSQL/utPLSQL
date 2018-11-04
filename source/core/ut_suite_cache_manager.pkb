create or replace package body ut_suite_cache_manager is
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

  function get_schema_parse_time(a_schema_name varchar2) return timestamp result_cache is
    l_cache_parse_time timestamp;
  begin
    select min(t.parse_time)
      into l_cache_parse_time
      from ut_suite_cache_schema t
     where object_owner = a_schema_name;
    return l_cache_parse_time;
  end;

  procedure save_cache(a_object_owner varchar2, a_suite_items ut_suite_items) is
    pragma autonomous_transaction;
    l_parse_time        timestamp;
    l_cached_parse_time timestamp;
    l_object_owner      varchar2(250) := upper(a_object_owner);
  begin
    if a_suite_items.count = 0 then
      return;
    end if;

    if a_suite_items(1).self_type != 'UT_LOGICAL_SUITE' then
      select min(parse_time)
        into l_cached_parse_time
        from ut_suite_cache t
      where t.object_name = a_suite_items(1).object_name
        and t.object_owner = a_suite_items(1).object_owner
        and rownum = 1;
    end if;

    select max(parse_time) into l_parse_time from table(a_suite_items) s;

    if l_parse_time > l_cached_parse_time or l_cached_parse_time is null then

      update ut_suite_cache_schema t
         set t.parse_time = l_parse_time
       where object_owner = l_object_owner;

      if sql%rowcount = 0 then
        insert into ut_suite_cache_schema
          (object_owner, parse_time)
        values (l_object_owner, l_parse_time);
      end if;

      delete from ut_suite_cache t
      where (t.object_name, t.object_owner)
         in (
            select upper(s.object_name), upper(s.object_owner)
              from table(a_suite_items) s where s.self_type != 'UT_LOGICAL_SUITE'
            );


      insert into ut_suite_cache t
        (
          self_type, path, object_owner, object_name, name,
          line_no, parse_time, description,
          rollback_type, disabled_flag, warnings
        )
      select self_type, path, upper(object_owner), upper(object_name), upper(name),
             line_no, parse_time, description,
             rollback_type, disabled_flag, warnings
        from table(a_suite_items) s
       where s.self_type = 'UT_LOGICAL_SUITE'
         and (s.object_owner, s.path) not in (select c.object_owner, c.path from ut_suite_cache c);

      insert into ut_suite_cache t
          (
              self_type, path, object_owner, object_name, name,
              line_no, parse_time, description,
              rollback_type, disabled_flag, warnings,
              before_all_list, after_all_list,
              before_each_list, after_each_list,
              before_test_list, after_test_list,
              expected_error_codes, item
          )
        with suites as ( select treat(value(x) as ut_suite) i
                           from table(a_suite_items) x
                          where x.self_type in( 'UT_SUITE', 'UT_SUITE_CONTEXT' ) )
        select s.i.self_type as self_type, s.i.path as path,
               upper(s.i.object_owner) as object_owner, upper(s.i.object_name) as object_name, upper(s.i.name) as name,
               s.i.line_no as line_no, s.i.parse_time as parse_time, s.i.description as description,
               s.i.rollback_type as rollback_type, s.i.disabled_flag as disabled_flag, s.i.warnings as warnings,
               s.i.before_all_list as before_all_list, s.i.after_all_list as after_all_list,
               null before_each_list, null after_each_list,
               null before_test_list, null after_test_list,
               null expected_error_codes, null item
        from suites s;

      insert into ut_suite_cache t
        (
          self_type, path, object_owner, object_name, name,
          line_no, parse_time, description,
          rollback_type, disabled_flag, warnings,
          before_all_list, after_all_list,
          before_each_list, after_each_list,
          before_test_list, after_test_list,
          expected_error_codes, item
        )
        with tests as ( select treat(value(x) as ut_test) t
                          from table ( a_suite_items ) x
                         where x.self_type in ( 'UT_TEST' ) )
      select s.t.self_type as self_type, s.t.path as path,
             upper(s.t.object_owner) as object_owner, upper(s.t.object_name) as object_name, upper(s.t.name) as name,
             s.t.line_no as line_no, s.t.parse_time as parse_time, s.t.description as description,
             s.t.rollback_type as rollback_type, s.t.disabled_flag as disabled_flag, s.t.warnings as warnings,
             null before_all_list, null after_all_list,
             s.t.before_each_list as before_each_list, s.t.after_each_list as after_each_list,
             s.t.before_test_list as before_test_list, s.t.after_test_list as after_test_list,
             s.t.expected_error_codes as expected_error_codes, s.t.item as item
        from tests s;

      commit;
    end if;
  end;

end ut_suite_cache_manager;
/
