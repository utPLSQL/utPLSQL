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

  function get_cached_suite_data(
    a_schema_name    varchar2,
    a_path           varchar2 := null,
    a_object_name    varchar2 := null,
    a_procedure_name varchar2 := null
  ) return t_cached_suites_cursor is
    l_path   varchar2( 4000 );
    l_result sys_refcursor;
  begin
    if a_path is null and a_object_name is not null then
      select min(path) into l_path
        from ut_suite_cache
       where object_owner = upper(a_schema_name) and object_name = lower(a_object_name) and
                 name = nvl(lower(a_procedure_name), name);
    else
      l_path := lower( a_path );
    end if;


    open l_result for
    select c.*
      from ut_suite_cache c
      --         join all_objects a
      --           on a.owner = x.object_owner
      --          and a.object_name = x.object_name
      --          and a.object_type = 'PACKAGE'
     where ( l_path like c.path || '.' || '%'
               or ( c.path like l_path || '%'
                      and c.object_name = nvl(lower(a_object_name), c.object_name)
                      and c.name = nvl(lower(a_procedure_name), c.name)
         )
       ) and c.object_owner = upper(a_schema_name)
     order by c.object_owner,
              replace(case
                      when c.self_type in ( 'UT_TEST' )
                        then substr(c.path, 1, instr(c.path, '.', -1) - 1)
                      else c.path
                      end, '.', chr(0)) desc nulls last,
              c.object_name desc,
              c.line_no desc;

    return l_result;
  end;


  function get_schema_ut_packages( a_schema_names ut_varchar2_rows ) return ut_object_names is
    l_results      ut_object_names := ut_object_names( );
    l_schema_names ut_varchar2_rows;
    l_object_names ut_varchar2_rows;
  begin
    select distinct c.object_owner, c.object_name
      bulk collect into l_schema_names, l_object_names
      from ut_suite_cache c
             --       join all_objects a
             --         on a.owner = c.object_owner
             --        and a.object_name = c.object_name
             --        and a.object_type = 'PACKAGE'
           join table ( a_schema_names ) s on c.object_owner = upper(s.column_value);
    l_results.extend( l_schema_names.count );
    for i in 1 .. l_schema_names.count loop
      l_results( i ) := ut_object_name( l_schema_names( i ), l_object_names( i ) );
    end loop;
    return l_results;
  end;

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
       where object_owner = a_object_owner;

      if sql%rowcount = 0 then
        insert into ut_suite_cache_schema
          (object_owner, parse_time)
        values (a_object_owner, l_parse_time);
      end if;

      delete from ut_suite_cache t
      where (t.object_name, t.object_owner)
         in (select s.object_name, s.object_owner from table(a_suite_items) s where s.self_type != 'UT_LOGICAL_SUITE');


      insert into ut_suite_cache t
        (
          self_type, path, object_owner, object_name, name,
          line_no, parse_time, description,
          rollback_type, disabled_flag, warnings
        )
      select self_type, path, object_owner, object_name, name,
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
               s.i.object_owner as object_owner, s.i.object_name as object_name, s.i.name as name,
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
             s.t.object_owner as object_owner, s.t.object_name as object_name, s.t.name as name,
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
