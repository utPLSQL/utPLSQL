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

  function get_suite_by(a_schema_name varchar2, a_path varchar2 := null, a_object_name varchar2 := null, a_procedure_name varchar2 := null) return sys_refcursor is
    l_result sys_refcursor;
  begin
    open l_result for
      select
             case self_type
                  when 'UT_TEST'
                       then ut_test(
                              self_type => self_type,
                              object_owner => object_owner, object_name => object_name, name => name,
                              description => description, path => path, rollback_type => rollback_type,
                              disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
                              start_time => null, end_time => null, result => null, warnings => warnings,
                              results_count => ut_results_counter(), transaction_invalidators => null,
                              before_each_list => before_each_list, before_test_list => before_test_list,
                              item => item, after_test_list => after_test_list, after_each_list => after_each_list,
                              all_expectations => null, failed_expectations => null,
                              parent_error_stack_trace => null, expected_error_codes => expected_error_codes
                 )
                 end as test_item,
             case self_type
                  when 'UT_SUITE'
                       then ut_suite(
                              self_type => self_type,
                              object_owner => object_owner, object_name => object_name, name => name,
                              description => description, path => path, rollback_type => rollback_type,
                              disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
                              start_time => null, end_time => null, result => null, warnings => warnings,
                              results_count => ut_results_counter(), transaction_invalidators => null,
                              items => ut_suite_items(),
                              before_all_list => before_all_list, after_all_list => after_all_list
                 )
                  when 'UT_SUITE_CONTEXT'
                       then ut_suite_context(
                              self_type => self_type,
                              object_owner => object_owner, object_name => object_name, name => name,
                              description => description, path => path, rollback_type => rollback_type,
                              disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
                              start_time => null, end_time => null, result => null, warnings => warnings,
                              results_count => ut_results_counter(), transaction_invalidators => null,
                              items => ut_suite_items(),
                              before_all_list => before_all_list, after_all_list => after_all_list
                 )
                  when 'UT_LOGICAL_SUITE'
                       then ut_logical_suite(
                              self_type => self_type,
                              object_owner => object_owner, object_name => object_name, name => name,
                              description => description, path => path, rollback_type => rollback_type,
                              disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
                              start_time => null, end_time => null, result => null, warnings => warnings,
                              results_count => ut_results_counter(), transaction_invalidators => null,
                              items => ut_suite_items()
                 )
             end as logical_suite,
             length(path) - length( replace(path, '.') )+1 as path_level
      from ut_suite_cache x
      where (  a_path like path ||'.'||'%'
             or ( path like a_path || '%'
                    and object_name = nvl(lower(a_object_name), object_name)
                    and name = nvl(lower(a_procedure_name), name)
                   )
            )
          and object_owner = upper(a_schema_name)
      order by path desc, object_name, line_no;
    
    return l_result;
  end;
  
--   function get_suite_by(a_schema_name varchar2, a_path varchar2 := null, a_object_name varchar2 := null, a_procedure_name varchar2 := null) return sys_refcursor is
--     l_filter varchar2(1000);
--     l_result sys_refcursor;
--     l_owner  varchar2(250) := ut_utils.ut_owner();
--   begin
--     if a_object_name is not null then
--       l_filter := ' object_name = lower(:a_object_name)';
--       if a_procedure_name is not null then
--         l_filter := l_filter || ' and name = lower(:a_procedure_name)';
--       else
--         l_filter := l_filter || ' and :a_procedure_name is null';
--       end if;
--     else
--       l_filter := ' :a_object_name is null and :a_procedure_name is null';
--     end if;
--     open l_result for q'[
--       select
--              case self_type
--                   when 'UT_TEST'
--                        then ]'||l_owner||q'[.ut_test(
--                               self_type => self_type,
--                               object_owner => object_owner, object_name => object_name, name => name,
--                               description => description, path => path, rollback_type => rollback_type,
--                               disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
--                               start_time => null, end_time => null, result => null, warnings => warnings,
--                               results_count => ut_results_counter(), transaction_invalidators => null,
--                               before_each_list => before_each_list, before_test_list => before_test_list,
--                               item => item, after_test_list => after_test_list, after_each_list => after_each_list,
--                               all_expectations => null, failed_expectations => null,
--                               parent_error_stack_trace => null, expected_error_codes => expected_error_codes
--                  )
--                  end as test_item,
--              case self_type
--                   when 'UT_SUITE'
--                        then ]'||l_owner||q'[.ut_suite(
--                               self_type => self_type,
--                               object_owner => object_owner, object_name => object_name, name => name,
--                               description => description, path => path, rollback_type => rollback_type,
--                               disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
--                               start_time => null, end_time => null, result => null, warnings => warnings,
--                               results_count => ]'||l_owner||q'[.ut_results_counter(), transaction_invalidators => null,
--                               items => ut_suite_items(),
--                               before_all_list => before_all_list, after_all_list => after_all_list
--                  )
--                   when 'UT_SUITE_CONTEXT'
--                        then ]'||l_owner||q'[.ut_suite_context(
--                               self_type => self_type,
--                               object_owner => object_owner, object_name => object_name, name => name,
--                               description => description, path => path, rollback_type => rollback_type,
--                               disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
--                               start_time => null, end_time => null, result => null, warnings => warnings,
--                               results_count => ]'||l_owner||q'[.ut_results_counter(), transaction_invalidators => null,
--                               items => ut_suite_items(),
--                               before_all_list => before_all_list, after_all_list => after_all_list
--                  )
--                   when 'UT_LOGICAL_SUITE'
--                        then ]'||l_owner||q'[.ut_logical_suite(
--                               self_type => self_type,
--                               object_owner => object_owner, object_name => object_name, name => name,
--                               description => description, path => path, rollback_type => rollback_type,
--                               disabled_flag => disabled_flag, line_no => line_no, parse_time => parse_time,
--                               start_time => null, end_time => null, result => null, warnings => warnings,
--                               results_count => ]'||l_owner||q'[.ut_results_counter(), transaction_invalidators => null,
--                               items => ut_suite_items()
--                  )
--              end as logical_suite,
--              length(path) - length( replace(path, '.') )+1 as path_level
--       from ]'||l_owner||q'[.ut_suite_cache x
--       where (  :a_path like path ||'.'||'%'
--              or path like :a_path ||'%' and ]'||l_filter||q'[ )
--           and object_owner = upper(:a_schema_name)
--       order by path desc, object_name, line_no]'
--     using a_path, a_path, a_object_name, a_procedure_name, a_schema_name;
--
--     return l_result;
--   end;
--
  function cached_suite_by_path(a_schema_name varchar2, a_path varchar2) return sys_refcursor is
  begin
    return get_suite_by(a_schema_name, a_path);
  end;

  function cached_suite_by_package(a_schema_name varchar2, a_object_name varchar2, a_procedure_name varchar2) return sys_refcursor is
    l_path varchar2(4000);
  begin
    select min(path) into l_path
    from ut_suite_cache
    where object_owner = upper(a_schema_name)
      and object_name = lower(a_object_name)
      and name = nvl(lower(a_procedure_name),name);

    return get_suite_by(a_schema_name, l_path, a_object_name, a_procedure_name );
  end;

  function cached_suite_by_schema(a_schema_name varchar2) return sys_refcursor is
  begin
    return get_suite_by(a_schema_name);
  end;

  procedure save_cache(a_suite_items ut_suite_items) is
    pragma autonomous_transaction;
    l_annotation_parse_time date;
    l_suite_parse_time    date;
  begin
    if a_suite_items.count = 0 then
      return;
    end if;
    if a_suite_items(1).self_type != 'UT_LOGICAL_SUITE' then
      select min(parse_time)
          into l_suite_parse_time from ut_suite_cache t
      where t.object_name = a_suite_items(1).object_name
          and t.object_owner = a_suite_items(1).object_owner
          and rownum = 1;
    end if;

    l_annotation_parse_time := a_suite_items(1).parse_time;

    if l_annotation_parse_time > l_suite_parse_time or l_suite_parse_time is null then

      merge into ut_suite_cache_schema t
        using(select object_owner, max(parse_time) parse_time from table(a_suite_items) group by object_owner) s
           on (s.object_owner = t.object_owner)
      when matched then update
        set t.parse_time = s.parse_time
      where s.parse_time > t.parse_time
      when not matched then
        insert (object_owner, parse_time)
        values (s.object_owner, s.parse_time);

      delete from ut_suite_cache t
      where (t.object_name, t.object_owner)
         in (select s.object_name, s.object_owner from table(a_suite_items) s where s.self_type != 'UT_LOGICAL_SUITE');

      merge into ut_suite_cache t
        using (
          select self_type, path, object_owner, object_name, name,
                 line_no, parse_time, description,
                 rollback_type, disabled_flag, warnings
            from table(a_suite_items) x where x.self_type = 'UT_LOGICAL_SUITE'
        ) s
        on (t.object_name = s.object_name and t.object_owner = s.object_owner)
      when not matched then
        insert (
          self_type, path, object_owner, object_name, name,
          line_no, parse_time, description,
          rollback_type, disabled_flag, warnings
        )
        values (
          s.self_type, s.path, s.object_owner, s.object_name, s.name,
          s.line_no, s.parse_time, s.description,
          s.rollback_type, s.disabled_flag, s.warnings
        );


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
        with
            suite_items as ( select value(x) item from table(a_suite_items) x ),
            suites as (
              select treat(item as ut_suite) i from suite_items s
              where s.item.self_type in ('UT_SUITE','UT_SUITE_CONTEXT')
          ),
            tests as (
              select treat(item as ut_test) t from suite_items s
              where s.item.self_type in ('UT_TEST')
          )
        select s.i.self_type as self_type, s.i.path as path,
               s.i.object_owner as object_owner, s.i.object_name as object_name, s.i.name as name,
               s.i.line_no as line_no, s.i.parse_time as parse_time, s.i.description as description,
               s.i.rollback_type as rollback_type, s.i.disabled_flag as disabled_flag, s.i.warnings as warnings,
               s.i.before_all_list as before_all_list, s.i.after_all_list as after_all_list,
               null before_each_list, null after_each_list,
               null before_test_list, null after_test_list,
               null expected_error_codes, null item
        from suites s
        union all
        select s.t.self_type as self_type, s.t.path as path,
               s.t.object_owner as object_owner, s.t.object_name as object_name, s.t.name as name,
               s.t.line_no as line_no, s.t.parse_time as parse_time, s.t.description as description,
               s.t.rollback_type as rollback_type, s.t.disabled_flag as disabled_flag, s.t.warnings as warnings,
               null before_all_list, null after_all_list,
               s.t.before_each_list as before_each_list, s.t.after_each_list as after_each_list,
               s.t.before_test_list as before_test_list, s.t.after_test_list as after_test_list,
               s.t.expected_error_codes as expected_error_codes, s.t.item as item
        from tests s;
    end if;
    commit;
  end;
end ut_suite_cache_manager;
/
