create or replace package body ut_suite_manager is
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

  gc_suitpath_error_message constant varchar2(100) := 'Suitepath exceeds 1000 CHAR on: ';

  gc_get_cache_suite_sql    constant varchar2(32767) :=
    q'[with
      suite_items as (
        select  /*+ cardinality(c 100) */ c.*
         from {:owner:}.ut_suite_cache c
         where 1 = 1 {:object_list:}
               and c.object_owner = '{:object_owner:}'
               and ( {:path:}
                     and {:object_name:}
                     and {:procedure_name:}
                   )
        )
      ),
      {:tags:},
      suitepaths as (
        select distinct substr(path,1,instr(path,'.',-1)-1) as suitepath,
                        path,
                        object_owner
          from {:suite_item_name:}
         where self_type = 'UT_SUITE'
      ),
        gen as (
        select rownum as pos
          from xmltable('1 to 20')
      ),
      suitepath_part AS (
        select distinct
                        substr(b.suitepath, 1, instr(b.suitepath || '.', '.', 1, g.pos) -1) as path,
                        object_owner
          from suitepaths b
               join gen g
                 on g.pos <= regexp_count(b.suitepath, '\w+')
      ),
      logical_suite_data as (
        select 'UT_LOGICAL_SUITE' as self_type, p.path, p.object_owner,
               upper( substr(p.path, instr( p.path, '.', -1 ) + 1 ) ) as object_name,
               cast(null as {:owner:}.ut_executables) as x,
               cast(null as {:owner:}.ut_integer_list) as y,
               cast(null as {:owner:}.ut_executable_test) as z
          from suitepath_part p
         where p.path
           not in (select s.path from suitepaths s)
      ),
      logical_suites as (
        select to_number(null) as id, s.self_type, s.path, s.object_owner, s.object_name,
               s.object_name as name, null as line_no, null as parse_time,
               null as description, null as rollback_type, 0 as disabled_flag,
               {:owner:}.ut_varchar2_rows() as warnings,
               s.x as before_all_list, s.x as after_all_list,
               s.x as before_each_list, s.x as before_test_list,
               s.x as after_each_list, s.x as after_test_list,
               s.y as expected_error_codes, null as test_tags,
               s.z as item
          from logical_suite_data s
      ),
      items as (
        select * from {:suite_item_name:}
        union all
        select * from logical_suites
      )
    select c.*
      from items c
     order by c.object_owner,{:random_seed:}]';

  type t_path_item is record (
    object_name    varchar2(250),
    procedure_name varchar2(250),
    suite_path     varchar2(4000)
  );
  type t_path_items is table of t_path_item;
  type t_schema_paths is table of t_path_items index by varchar2(250 char);

  subtype t_cached_suite is ut_suite_cache%rowtype;
  type tt_cached_suites  is table of t_cached_suite;
  type t_cached_suites_cursor is ref cursor return t_cached_suite;

  type t_item_levels is table of ut_suite_items index by binary_integer;
  ------------------

  procedure validate_paths(a_paths in ut_varchar2_list) is
    l_path varchar2(32767);
  begin
    if a_paths is null or a_paths.count = 0 then
      raise_application_error(ut_utils.gc_path_list_is_empty, 'Path list is empty');
    else
      for i in 1 .. a_paths.count loop
        l_path := a_paths(i);
        if l_path is null or not (regexp_like(l_path, '^[A-Za-z0-9$#_]+(\.[A-Za-z0-9$#_]+){0,2}$') or regexp_like(l_path, '^([A-Za-z0-9$#_]+)?:[A-Za-z0-9$#_]+(\.[A-Za-z0-9$#_]+)*$')) then
          raise_application_error(ut_utils.gc_invalid_path_format, 'Invalid path format: ' || nvl(l_path, 'NULL'));
        end if;
      end loop;
    end if;
  end;

  function trim_and_lower_paths( a_paths ut_varchar2_list) return ut_varchar2_list is
    l_paths_temp ut_varchar2_list := ut_varchar2_list();
  begin
    l_paths_temp.extend(a_paths.count);
    for i in 1 .. a_paths.count loop
      l_paths_temp(i) := trim(lower(a_paths(i)));
    end loop;
    return l_paths_temp;
  end;

  function resolve_schema_names(a_paths in out nocopy ut_varchar2_list) return ut_varchar2_rows is
    l_schema          varchar2(4000);
    l_object          varchar2(4000);
    l_schema_names    ut_varchar2_rows := ut_varchar2_rows();
    c_current_schema  constant all_tables.owner%type := sys_context('USERENV','CURRENT_SCHEMA');
  begin
    a_paths := set( trim_and_lower_paths( a_paths) );

    validate_paths(a_paths);

    for i in 1 .. a_paths.count loop
      --if path is suite-path
      if regexp_like(a_paths(i), '^([A-Za-z0-9$#_]+)?:') then
      --get schema name / path
        l_schema := regexp_substr(a_paths(i), '^([A-Za-z0-9$#_]+)?:',subexpression => 1);
        -- transform ":path1[.path2]" to "schema:path1[.path2]"
        if l_schema is not null then
          l_schema := sys.dbms_assert.schema_name(upper(l_schema));
        else
          a_paths(i)   := c_current_schema || a_paths(i);
          l_schema     := c_current_schema;
        end if;
      else
        -- get schema name / object.[procedure] name
        -- When path is one of: schema or schema.package[.object] or package[.object]
        -- transform it back to schema[.package[.object]]
        begin
          l_object := regexp_substr(a_paths(i), '^[A-Za-z0-9$#_]+');
          l_schema := sys.dbms_assert.schema_name(upper(l_object));
        exception
          when sys.dbms_assert.invalid_schema_name then
            if ut_metadata.package_exists_in_cur_schema(upper(l_object)) then
              a_paths(i) := c_current_schema || '.' || a_paths(i);
              l_schema := c_current_schema;
            else
              raise;
            end if;
        end;
      end if;
      l_schema_names.extend;
      l_schema_names(l_schema_names.last) := l_schema;
    end loop;

    return l_schema_names;
  end;

  procedure resolve_schema_names(a_paths in out nocopy ut_varchar2_list) is
    l_schema_names    ut_varchar2_rows;
  begin
    l_schema_names := resolve_schema_names(a_paths);
  end;

  function group_paths_by_schema(a_paths ut_varchar2_list) return t_schema_paths is
    c_package_path_regex constant varchar2(100) := '^([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_]+))?(\.([A-Za-z0-9$#_]+))?$';
    l_schema             varchar2(4000);
    l_empty_result       t_path_item;
    l_result             t_path_item;
    l_results            t_schema_paths;
  begin
    for i in 1 .. a_paths.count loop
      l_result := l_empty_result;
      if a_paths(i) like '%:%' then
        l_schema := upper(regexp_substr(a_paths(i),'^[^.:]+'));
        l_result.suite_path := ltrim(regexp_substr(a_paths(i),'[.:].*$'),':');
      else
        l_schema := regexp_substr(a_paths(i), c_package_path_regex, subexpression => 1);
        l_result.object_name   := regexp_substr(a_paths(i), c_package_path_regex, subexpression => 3);
        l_result.procedure_name := regexp_substr(a_paths(i), c_package_path_regex, subexpression => 5);
      end if;
      if l_results.exists(l_schema) then
        l_results(l_schema).extend;
        l_results(l_schema)(l_results(l_schema).last) := l_result;
      else
        l_results(l_schema) := t_path_items(l_result);
      end if;
    end loop;
    return l_results;
  end;


  function sort_by_seq_no(
    a_list ut_executables
  ) return ut_executables is
    l_results ut_executables := ut_executables();
  begin
    if a_list is not null then
      l_results.extend(a_list.count);
      for i in 1 .. a_list.count loop
        l_results(a_list(i).seq_no) := a_list(i);
      end loop;
    end if;
    return l_results;
  end;

  procedure reverse_list_order(
    a_list in out nocopy ut_suite_items
  ) is
    l_start_idx pls_integer;
    l_end_idx   pls_integer;
    l_item      ut_suite_item;
  begin
    l_start_idx := a_list.first;
    l_end_idx := a_list.last;
    while l_start_idx < l_end_idx loop
      l_item := a_list(l_start_idx);
      a_list(l_start_idx) := a_list(l_end_idx);
      a_list(l_end_idx) := l_item;
      l_end_idx := a_list.prior(l_end_idx);
      l_start_idx := a_list.next(l_start_idx);
    end loop;
  end;

  function get_logical_suite(
    a_rows tt_cached_suites,
    a_idx pls_integer,
    a_level             pls_integer,
    a_prev_level        pls_integer,
    a_items_at_level    t_item_levels
  ) return ut_suite_item is
    l_result ut_suite_item;
  begin
      case a_rows( a_idx ).self_type
        when 'UT_SUITE' then
          l_result :=
            case when a_prev_level > a_level then
                ut_suite(
                  self_type => a_rows( a_idx ).self_type,
                  object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
                  name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
                  rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
                  line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
                  start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
                  results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                  items => a_items_at_level(a_prev_level),
                  before_all_list => sort_by_seq_no( a_rows( a_idx ).before_all_list), after_all_list => sort_by_seq_no(
                    a_rows( a_idx ).after_all_list), tags => a_rows(a_idx).tags
                )
            else
                ut_suite(
                  self_type => a_rows( a_idx ).self_type,
                  object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
                  name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
                  rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
                  line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
                  start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
                  results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                  items => ut_suite_items(),
                  before_all_list => sort_by_seq_no( a_rows( a_idx ).before_all_list), after_all_list => sort_by_seq_no(
                    a_rows( a_idx ).after_all_list), tags => a_rows(a_idx).tags
                )
            end;
        when 'UT_SUITE_CONTEXT' then
          l_result :=
            case when a_prev_level > a_level then
              ut_suite_context(
                self_type => a_rows( a_idx ).self_type,
                object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
                name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
                line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
                start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
                results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                items => a_items_at_level(a_prev_level),
                before_all_list => sort_by_seq_no( a_rows( a_idx ).before_all_list), after_all_list => sort_by_seq_no(
                  a_rows( a_idx ).after_all_list), tags => a_rows(a_idx).tags
              )
            else
              ut_suite_context(
                self_type => a_rows( a_idx ).self_type,
                object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
                name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
                line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
                start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
                results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                items => ut_suite_items(),
                before_all_list => sort_by_seq_no( a_rows( a_idx ).before_all_list), after_all_list => sort_by_seq_no(
                  a_rows( a_idx ).after_all_list), tags => a_rows(a_idx).tags
              )
            end;
        when 'UT_LOGICAL_SUITE' then
          l_result :=
            case when a_prev_level > a_level then
              ut_logical_suite(
                self_type => a_rows( a_idx ).self_type,
                object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
                name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
                line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
                start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
                results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                items => a_items_at_level(a_prev_level), tags => null
              )
            else
              ut_logical_suite(
                self_type => a_rows( a_idx ).self_type,
                object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
                name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
                line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
                start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
                results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                items => ut_suite_items(), tags => null
              )
            end;
        when 'UT_TEST' then
          l_result :=
            ut_test(
              self_type => a_rows(a_idx).self_type,
              object_owner => a_rows(a_idx).object_owner, object_name => lower(a_rows(a_idx).object_name),
              name => lower(a_rows(a_idx).name), description => a_rows(a_idx).description, path => a_rows(a_idx).path,
              rollback_type => a_rows(a_idx).rollback_type, disabled_flag => a_rows(a_idx).disabled_flag,
              line_no => a_rows(a_idx).line_no, parse_time => a_rows(a_idx).parse_time,
              start_time => null, end_time => null, result => null, warnings => a_rows(a_idx).warnings,
              results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
              before_each_list => sort_by_seq_no(a_rows(a_idx).before_each_list), before_test_list => sort_by_seq_no(a_rows(a_idx).before_test_list),
              item => a_rows(a_idx).item,
              after_test_list => sort_by_seq_no(a_rows(a_idx).after_test_list), after_each_list => sort_by_seq_no(a_rows(a_idx).after_each_list),
              all_expectations => ut_expectation_results(), failed_expectations => ut_expectation_results(),
              parent_error_stack_trace => null, expected_error_codes => a_rows(a_idx).expected_error_codes,
              tags => a_rows(a_idx).tags
            );
      end case;
    l_result.results_count.warnings_count := l_result.warnings.count;
    return l_result;
  end;
  
  procedure reconstruct_from_cache(
    a_suites            in out nocopy ut_suite_items,
    a_suite_data_cursor sys_refcursor
  ) is
    c_bulk_limit        constant pls_integer := 1000;
    l_items_at_level    t_item_levels;
    l_rows              tt_cached_suites;
    l_level             pls_integer;
    l_prev_level        pls_integer;
    l_idx               integer;
  begin
    loop
      fetch a_suite_data_cursor bulk collect into l_rows limit c_bulk_limit;

      l_idx := l_rows.first;
      while l_idx is not null loop
        l_level := length(l_rows(l_idx).path) - length( replace(l_rows(l_idx).path, '.') ) + 1;
        if l_level > 1 then
          if not l_items_at_level.exists(l_level) then
            l_items_at_level(l_level) := ut_suite_items();
          end if;
          l_items_at_level(l_level).extend;
          pragma inline(get_logical_suite, 'YES');
          l_items_at_level(l_level)(l_items_at_level(l_level).last) := get_logical_suite(l_rows, l_idx, l_level,l_prev_level, l_items_at_level );
        else
          a_suites.extend;
          pragma inline(get_logical_suite, 'YES');
          a_suites(a_suites.last) := get_logical_suite(l_rows, l_idx, l_level,l_prev_level, l_items_at_level );
        end if;
        if l_prev_level > l_level then
          l_items_at_level(l_prev_level).delete;
        end if;
        l_prev_level := l_level;
        l_idx := l_rows.next(l_idx);
      end loop;
      exit when a_suite_data_cursor%NOTFOUND;
    end loop;

    reverse_list_order( a_suites );

    for i in 1 .. a_suites.count loop
      a_suites( i ).set_rollback_type( a_suites( i ).get_rollback_type );
    end loop;
    close a_suite_data_cursor;
  end reconstruct_from_cache;

  function get_missing_objects(a_object_owner varchar2) return ut_varchar2_rows is
    l_rows         sys_refcursor;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_cursor_text  varchar2(32767);
    l_result       ut_varchar2_rows;
    l_object_owner varchar2(250);
  begin
    l_object_owner := sys.dbms_assert.qualified_sql_name(a_object_owner);
    l_cursor_text :=
      q'[select i.object_name
         from ]'||l_ut_owner||q'[.ut_suite_cache_package i
         where
           not exists (
              select 1  from ]'||l_ut_owner||q'[.ut_annotation_cache_info o
               where o.object_owner = i.object_owner
                 and o.object_name = i.object_name
                 and o.object_type = 'PACKAGE'
              )
          and i.object_owner = ']'||l_object_owner||q'[']';
    open l_rows for l_cursor_text;
    fetch l_rows bulk collect into l_result limit 1000000;
    close l_rows;
    return l_result;
  end;

  function get_object_names_sql(a_skip_all_objects boolean ) return varchar2 is
  begin
    return case when not a_skip_all_objects then q'[
               and exists
                   ( select 1
                       from all_objects a
                      where a.object_name = c.object_name
                        and a.owner       = '{:object_owner:}'
                        and a.owner       = c.object_owner
                        and a.object_type = 'PACKAGE'
                   )]' else null end;
  end;

  function get_path_sql(a_path in varchar2) return varchar2 is
  begin
    return case when a_path is not null then q'[
                      :l_path||'.' like c.path || '.%' /*all children and self*/
                     or ( c.path||'.' like :l_path || '.%'  --all parents
                            ]'
                           else ' :l_path is null  and ( :l_path is null ' end;
  end;

  function get_object_name_sql(a_object_name in varchar2) return varchar2 is
  begin
    return case when a_object_name is not null
      then ' c.object_name = :a_object_name '
         else ' :a_object_name is null' end;
  end;

  function get_procedure_name_sql(a_procedure_name in varchar2) return varchar2 is
  begin
    return case when a_procedure_name is not null
      then ' c.name = :a_procedure_name'
      else ' :a_procedure_name is null' end;
  end;

  function get_tags_sql(a_tags_count in integer) return varchar2 is
  begin
  return case when a_tags_count > 0 then
      q'[filter_tags as (
        select c.*
        from suite_items c
        where c.tags multiset intersect :a_tag_list is not empty
      ),
       suite_items_tags as (
       select c.* from suite_items c
       where exists (select 1 from filter_tags t where
          t.path||'.' like c.path || '.%' /*all children and self*/
          or c.path||'.' like t.path || '.%'  --all parents
          )
       )]'
       else
       q'[dummy as (select 'x' from dual where :a_tag_list is null )]'
       end;
  end;

  function get_random_seed_sql(a_random_seed positive) return varchar2 is
  begin
    return case
            when a_random_seed is null then q'[
              replace(
                case
                  when c.self_type in ( 'UT_TEST' )
                    then substr(c.path, 1, instr(c.path, '.', -1) )
                    else c.path
                end, '.', chr(0)
              ) desc nulls last,
              c.object_name desc,
              c.line_no,
              :a_random_seed]'
            else
              ' {:owner:}.ut_runner.hash_suite_path(
                c.path, :a_random_seed
              ) desc nulls last'
              end;
  end;

  function get_cached_suite_data(
    a_object_owner     varchar2,
    a_path             varchar2 := null,
    a_object_name      varchar2 := null,
    a_procedure_name   varchar2 := null,
    a_skip_all_objects boolean  := false,
    a_random_seed      positive,
    a_tags             ut_varchar2_rows := null
  ) return t_cached_suites_cursor is
    l_path            varchar2(4000);
    l_result          sys_refcursor;
    l_ut_owner        varchar2(250) := ut_utils.ut_owner;
    l_sql             varchar2(32767);
    l_suite_item_name varchar2(20);
    l_tags            ut_varchar2_rows := coalesce(a_tags,ut_varchar2_rows());
    l_object_owner    varchar2(250);
    l_object_name     varchar2(250);
    l_procedure_name  varchar2(250);
  begin
    if a_object_owner is not null then
      l_object_owner := sys.dbms_assert.qualified_sql_name(a_object_owner);
      end if;
    if a_object_name is not null then
      l_object_name := sys.dbms_assert.qualified_sql_name(a_object_name);
      end if;
    if a_procedure_name is not null then
      l_procedure_name := sys.dbms_assert.qualified_sql_name(a_procedure_name);
      end if;
    if a_path is null and a_object_name is not null then
      execute immediate 'select min(path)
      from '||l_ut_owner||q'[.ut_suite_cache
     where object_owner = :a_object_owner
           and object_name = :a_object_name
           and name = nvl(:a_procedure_name, name)]'
      into l_path using upper(l_object_owner), upper(l_object_name), upper(a_procedure_name);
    else
      if a_path is not null then
        l_path := lower(sys.dbms_assert.qualified_sql_name(a_path));
      end if;
    end if;
    l_suite_item_name := case when l_tags.count > 0 then 'suite_items_tags' else 'suite_items' end;

    l_sql := gc_get_cache_suite_sql;
    l_sql := replace(l_sql,'{:suite_item_name:}',l_suite_item_name);
    l_sql := replace(l_sql,'{:object_list:}',get_object_names_sql(a_skip_all_objects));
    l_sql := replace(l_sql,'{:object_owner:}',upper(l_object_owner));
    l_sql := replace(l_sql,'{:path:}',get_path_sql(l_path));
    l_sql := replace(l_sql,'{:object_name:}',get_object_name_sql(l_object_name));
    l_sql := replace(l_sql,'{:procedure_name:}',get_procedure_name_sql(l_procedure_name));
    l_sql := replace(l_sql,'{:tags:}',get_tags_sql(l_tags.count));
    l_sql := replace(l_sql,'{:random_seed:}',get_random_seed_sql(a_random_seed));
    l_sql := replace(l_sql,'{:owner:}',l_ut_owner);

    ut_event_manager.trigger_event(ut_event_manager.gc_debug, ut_key_anyvalues().put('l_sql',l_sql) );

    open l_result for l_sql using l_path, l_path, upper(a_object_name), upper(a_procedure_name), l_tags, a_random_seed;
    return l_result;
  end;

  function can_skip_all_objects_scan(
    a_owner_name         varchar2
  ) return boolean is
  begin
    return sys_context( 'userenv', 'current_schema' ) = a_owner_name or ut_metadata.user_has_execute_any_proc() or ut_trigger_check.is_alive();
  end;

  procedure build_and_cache_suites(
    a_owner_name        varchar2,
    a_annotated_objects sys_refcursor
  ) is
    l_annotated_objects  ut_annotated_objects;
    l_suite_items        ut_suite_items;
    
    l_bad_suitepath_obj ut_varchar2_list := ut_varchar2_list();   
    ex_string_too_small exception;
    pragma exception_init (ex_string_too_small,-06502);
  begin
    ut_event_manager.trigger_event('build_and_cache_suites - start');
    loop
      fetch a_annotated_objects bulk collect into l_annotated_objects limit 10;

      for i in 1 .. l_annotated_objects.count loop
        begin
          ut_suite_builder.create_suite_item_list( l_annotated_objects( i ), l_suite_items );
        exception
          when ex_string_too_small then
            ut_utils.append_to_list(l_bad_suitepath_obj,a_owner_name||'.'||l_annotated_objects( i ).object_name);
        end;
        ut_suite_cache_manager.save_object_cache(
          a_owner_name,
          l_annotated_objects( i ).object_name,
          l_annotated_objects( i ).parse_time,
          l_suite_items
        );
      end loop;
      exit when a_annotated_objects%notfound;
    end loop;
    close a_annotated_objects;
    
    --Check for any invalid suitepath objects
    if l_bad_suitepath_obj.count > 0 then
      raise_application_error(
        ut_utils.gc_value_too_large,
        ut_utils.to_string(gc_suitpath_error_message||ut_utils.table_to_clob(l_bad_suitepath_obj,','))
      );
    end if;
    ut_event_manager.trigger_event('build_and_cache_suites - end');
  end;

  procedure refresh_cache(
    a_owner_name         varchar2
  ) is
    l_annotations_cursor    sys_refcursor;
    l_suite_cache_time      timestamp;
  begin
    ut_event_manager.trigger_event('refresh_cache - start');
    l_suite_cache_time := ut_suite_cache_manager.get_schema_parse_time(a_owner_name);
    l_annotations_cursor := ut_annotation_manager.get_annotated_objects(
      a_owner_name, 'PACKAGE', l_suite_cache_time
    );

    build_and_cache_suites(a_owner_name, l_annotations_cursor);

    if can_skip_all_objects_scan(a_owner_name) or ut_metadata.is_object_visible( 'dba_objects') then
      ut_suite_cache_manager.remove_from_cache( a_owner_name, get_missing_objects(a_owner_name) );
    end if;

    ut_event_manager.trigger_event('refresh_cache - end');
  end;

  procedure add_suites_for_path(
    a_owner_name     varchar2,
    a_path           varchar2 := null,
    a_object_name    varchar2 := null,
    a_procedure_name varchar2 := null,
    a_suites         in out nocopy ut_suite_items,
    a_random_seed    positive,
    a_tags           ut_varchar2_rows := null
  ) is
  begin
    refresh_cache(a_owner_name);

    reconstruct_from_cache(
      a_suites,
      get_cached_suite_data(
        a_owner_name,
        a_path,
        a_object_name,
        a_procedure_name,
        can_skip_all_objects_scan(a_owner_name),
        a_random_seed,
        a_tags
      )
    );

  end;

  -----------------------------------------------
  -----------------------------------------------
  -------------  Public definitions -------------

  function build_suites_from_annotations(
    a_owner_name        varchar2,
    a_annotated_objects sys_refcursor,
    a_path              varchar2 := null,
    a_object_name       varchar2 := null,
    a_procedure_name    varchar2 := null,
    a_skip_all_objects  boolean := false
  ) return ut_suite_items is
    l_suites             ut_suite_items := ut_suite_items();
  begin
    build_and_cache_suites(a_owner_name, a_annotated_objects);

    reconstruct_from_cache(
      l_suites,
      get_cached_suite_data(
        a_owner_name,
        a_path,
        a_object_name,
        a_procedure_name,
        a_skip_all_objects,
        null,
        null
      )
    );
    return l_suites;
  end;

  function get_schema_ut_packages(a_schema_names ut_varchar2_rows) return ut_object_names is
    l_results      ut_object_names := ut_object_names( );
    l_schema_names ut_varchar2_rows;
    l_object_names ut_varchar2_rows;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_need_all_objects_scan boolean := true;
  begin
    -- if current user is the onwer or current user has execute any procedure privilege
    if ut_metadata.user_has_execute_any_proc()
      or (a_schema_names is not null and a_schema_names.count = 1
      and sys_context('userenv','current_schema') = a_schema_names(1))
    then
      l_need_all_objects_scan := false;
    end if;

    for i in 1 .. a_schema_names.count loop
      refresh_cache(a_schema_names(i));
    end loop;

    execute immediate 'select c.object_owner, c.object_name
      from '||l_ut_owner||q'[.ut_suite_cache_package c
           join table ( :a_schema_names ) s
             on c.object_owner = upper(s.column_value)]'
      || case when l_need_all_objects_scan then q'[
     where exists
          (select 1 from  all_objects a
            where a.owner = c.object_owner
                  and a.object_name = c.object_name
                  and a.object_type = 'PACKAGE')
      ]' end
    bulk collect into l_schema_names, l_object_names using a_schema_names;
    l_results.extend( l_schema_names.count );
    for i in 1 .. l_schema_names.count loop
      l_results( i ) := ut_object_name( l_schema_names( i ), l_object_names( i ) );
    end loop;
    return l_results;
  end;

  function get_schema_names(a_paths ut_varchar2_list) return ut_varchar2_rows is
    l_paths ut_varchar2_list;
  begin
    l_paths := a_paths;
    return resolve_schema_names(l_paths);
  end;

  function configure_execution_by_path(a_paths ut_varchar2_list, a_random_seed positive := null) return ut_suite_items is
    l_suites             ut_suite_items := ut_suite_items();
  begin
    configure_execution_by_path(a_paths, l_suites );
    return l_suites;
  end;

  procedure configure_execution_by_path(
    a_paths       ut_varchar2_list,
    a_suites      out nocopy ut_suite_items,
    a_random_seed positive   := null,
    a_tags        ut_varchar2_rows := ut_varchar2_rows()
  ) is
    l_paths              ut_varchar2_list := a_paths;
    l_path_items         t_path_items;
    l_path_item          t_path_item;
    l_schema             varchar2(4000);
    l_suites_count       pls_integer := 0;
    l_index              varchar2(4000 char);
    l_schema_paths       t_schema_paths;
  begin
    ut_event_manager.trigger_event('configure_execution_by_path - start');
    a_suites := ut_suite_items();
    --resolve schema names from paths and group paths by schema name
    resolve_schema_names(l_paths);

    l_schema_paths := group_paths_by_schema(l_paths);

    l_schema := l_schema_paths.first;
    while l_schema is not null loop
      l_path_items  := l_schema_paths(l_schema);
      for i in 1 .. l_path_items.count loop
        l_path_item := l_path_items(i);
          add_suites_for_path(
            upper(l_schema),
            l_path_item.suite_path,
            l_path_item.object_name,
            l_path_item.procedure_name,
            a_suites,
            a_random_seed,
            a_tags
          );
        if a_suites.count = l_suites_count then
          if l_path_item.suite_path is not null then
            raise_application_error(ut_utils.gc_suite_package_not_found,'No suite packages found for path '||l_schema||':'||l_path_item.suite_path|| '.');
          elsif l_path_item.procedure_name is not null then
            raise_application_error(ut_utils.gc_suite_package_not_found,'Suite test '||l_schema||'.'||l_path_item.object_name|| '.'||l_path_item.procedure_name||' does not exist');
          elsif l_path_item.object_name is not null then
            raise_application_error(ut_utils.gc_suite_package_not_found,'Suite package '||l_schema||'.'||l_path_item.object_name|| ' does not exist');
          end if;
        end if;
        l_index := a_suites.first;
        l_suites_count := a_suites.count;
      end loop;
      l_schema := l_schema_paths.next(l_schema);
    end loop;

    --propagate rollback type to suite items after organizing suites into hierarchy
    for i in 1 .. a_suites.count loop
      a_suites(i).set_rollback_type( a_suites(i).get_rollback_type() );
    end loop;

    ut_event_manager.trigger_event('configure_execution_by_path - start');
  end configure_execution_by_path;

  function get_suites_info(
    a_owner_name     varchar2, 
    a_package_name   varchar2 := null
  ) return sys_refcursor is
    l_result       sys_refcursor;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_owner_name   varchar2(250);
    l_package_name varchar2(250);
  begin
    if a_owner_name is not null then
      l_owner_name := sys.dbms_assert.qualified_sql_name(a_owner_name);
    end if;
    if a_package_name is not null then
      l_package_name := sys.dbms_assert.qualified_sql_name(a_package_name);
    end if;

    refresh_cache(l_owner_name);
    
    open l_result for
    q'[with
      suite_items as (
        select /*+ cardinality(c 100) */ c.*
          from ]'||l_ut_owner||q'[.ut_suite_cache c
         where 1 = 1 ]'||case when can_skip_all_objects_scan(l_owner_name) then q'[
               and exists
                   ( select 1
                       from all_objects a
                      where a.object_name = c.object_name
                        and a.owner       = ']'||upper(l_owner_name)||q'['
                        and a.owner       = c.object_owner
                        and a.object_type = 'PACKAGE'
                   )]' end ||q'[
               and c.object_owner = ']'||upper(l_owner_name)||q'['
               and ]'
               || case when l_package_name is not null
                  then 'c.object_name = :a_package_name'
                  else ':a_package_name is null' end
               || q'[
      ),
      suitepaths as (
        select distinct
               substr(path,1,instr(path,'.',-1)-1) as suitepath,
               path,
               object_owner
          from suite_items
         where self_type = 'UT_SUITE'
      ),
        gen as (
        select rownum as pos
          from xmltable('1 to 20')
      ),
      suitepath_part AS (
        select distinct
               substr(b.suitepath, 1, instr(b.suitepath || '.', '.', 1, g.pos) -1) as path,
               object_owner
          from suitepaths b
               join gen g
                 on g.pos <= regexp_count(b.suitepath, '\w+')
      ),
      logical_suites as (
        select 'UT_LOGICAL_SUITE' as item_type,
               p.path, p.object_owner,
               upper( substr(p.path, instr( p.path, '.', -1 ) + 1 ) ) as object_name
          from suitepath_part p
         where p.path
           not in (select s.path from suitepaths s)
      ),
      items as (
        select object_owner, object_name, name as item_name,
               description as item_description, self_type as item_type, line_no as item_line_no,
               path, disabled_flag,tags
          from suite_items
        union all
        select object_owner, object_name, object_name as item_name,
               null as item_description, item_type, null as item_line_no,
               s.path,  0 as disabled_flag, ]'||l_ut_owner||q'[.ut_varchar2_rows() as tags
          from logical_suites s
      )
    select ]'||l_ut_owner||q'[.ut_suite_item_info(
             object_owner, object_name, item_name, item_description,
             item_type, item_line_no, path, disabled_flag, tags
           )
      from items c]' using upper(l_package_name);

    return l_result;
  end;

  function suite_item_exists(
    a_owner_name     varchar2, 
    a_package_name   varchar2 := null, 
    a_procedure_name varchar2 := null,
    a_item_type      varchar2 := null
  ) return boolean is
    l_result         integer;
    l_ut_owner       varchar2(250) := ut_utils.ut_owner;
    l_owner_name     varchar2(250);
    l_package_name   varchar2(250);
    l_procedure_name varchar2(250);
  begin
    if a_owner_name is not null then
      l_owner_name := sys.dbms_assert.qualified_sql_name(a_owner_name);
    end if;
    if a_package_name is not null then
      l_package_name := sys.dbms_assert.qualified_sql_name(a_package_name);
    end if;
    if a_procedure_name is not null then
      l_procedure_name := sys.dbms_assert.qualified_sql_name(a_procedure_name);
    end if;

    refresh_cache(l_owner_name);

    execute immediate q'[
      select count(1) from dual
       where exists (
                select 1
                  from ]'||l_ut_owner||q'[.ut_suite_cache c
                 where 1 = 1 ]'||case when not can_skip_all_objects_scan(l_owner_name) then q'[
                       and exists
                           ( select 1
                               from all_objects a
                              where a.object_name = c.object_name
                                and a.owner       = :a_owner_name
                                and a.owner       = c.object_owner
                                and a.object_type = 'PACKAGE'
                           )]' else q'[
                       and :a_owner_name is not null ]' end ||q'[
                       and c.object_owner = :a_owner_name
                       and ]'
                       || case when l_package_name is not null
                          then 'c.object_name = :a_package_name'
                          else ':a_package_name is null' end
                       || q'[
                       and ]'
                       || case when l_procedure_name is not null
                          then 'c.name = :a_procedure_name'
                          else ':a_procedure_name is null' end
                       || q'[
             )]'
      into l_result 
      using 
        upper(l_owner_name), upper(l_owner_name),
        upper(l_package_name), upper(l_procedure_name);
    
    return l_result > 0;
  end;

end ut_suite_manager;
/
