create or replace package body ut_suite_manager is
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
  ) return ut_logical_suite is
  begin
    return
      case a_rows( a_idx ).self_type
        when 'UT_SUITE' then
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
                a_rows( a_idx ).after_all_list)
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
                a_rows( a_idx ).after_all_list)
            )
          end
        when 'UT_SUITE_CONTEXT' then
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
                a_rows( a_idx ).after_all_list)
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
                a_rows( a_idx ).after_all_list)
            )
          end
        when 'UT_LOGICAL_SUITE' then
          case when a_prev_level > a_level then
            ut_logical_suite(
              self_type => a_rows( a_idx ).self_type,
              object_owner => a_rows( a_idx ).object_owner, object_name => lower( a_rows( a_idx ).object_name),
              name => lower( a_rows( a_idx ).name), description => a_rows( a_idx ).description, path => a_rows( a_idx ).path,
              rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag,
              line_no => a_rows( a_idx ).line_no, parse_time => a_rows( a_idx ).parse_time,
              start_time => null, end_time => null, result => null, warnings => a_rows( a_idx ).warnings,
              results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
              items => a_items_at_level(a_prev_level)
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
              items => ut_suite_items()
            )
          end
      end;
  end;
  
  procedure reconstruct_from_cache(
    a_suites            in out nocopy ut_suite_items,
    a_suite_data_cursor sys_refcursor
  ) is
    c_bulk_limit        constant pls_integer := 1000;
    l_items_at_level    t_item_levels;
    l_rows              tt_cached_suites;
    l_logical_suite     ut_logical_suite;
    l_level             pls_integer;
    l_prev_level        pls_integer;
    l_idx               integer;
  begin
    loop
      fetch a_suite_data_cursor bulk collect into l_rows limit c_bulk_limit;
      exit when l_rows.count = 0;

      l_idx := l_rows.first;
      loop
        l_level := length(l_rows(l_idx).path) - length( replace(l_rows(l_idx).path, '.') ) + 1;
        if l_level > 1 then
          if not l_items_at_level.exists(l_level) then
            l_items_at_level(l_level) := ut_suite_items();
          end if;
          l_items_at_level(l_level).extend;
          if l_rows(l_idx).self_type = 'UT_TEST' then
            l_items_at_level(l_level)(l_items_at_level(l_level).last) :=
              ut_test(
                self_type => l_rows(l_idx).self_type,
                object_owner => l_rows(l_idx).object_owner, object_name => lower(l_rows(l_idx).object_name),
                name => lower(l_rows(l_idx).name), description => l_rows(l_idx).description, path => l_rows(l_idx).path,
                rollback_type => l_rows(l_idx).rollback_type, disabled_flag => l_rows(l_idx).disabled_flag,
                line_no => l_rows(l_idx).line_no, parse_time => l_rows(l_idx).parse_time,
                start_time => null, end_time => null, result => null, warnings => l_rows(l_idx).warnings,
                results_count => ut_results_counter(), transaction_invalidators => ut_varchar2_list(),
                before_each_list => sort_by_seq_no(l_rows(l_idx).before_each_list), before_test_list => sort_by_seq_no(l_rows(l_idx).before_test_list),
                item => l_rows(l_idx).item,
                after_test_list => sort_by_seq_no(l_rows(l_idx).after_test_list), after_each_list => sort_by_seq_no(l_rows(l_idx).after_each_list),
                all_expectations => ut_expectation_results(), failed_expectations => ut_expectation_results(),
                parent_error_stack_trace => null, expected_error_codes => l_rows(l_idx).expected_error_codes
              );
          else
            pragma inline(get_logical_suite, 'YES');
            l_items_at_level(l_level)(l_items_at_level(l_level).last) := get_logical_suite(l_rows, l_idx, l_level,l_prev_level, l_items_at_level );
           end if;
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
        exit when l_idx is null;
      end loop;
      exit when l_rows.count < c_bulk_limit;
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
    l_objects_view varchar2(200) := ut_metadata.get_dba_view('dba_objects');
    l_cursor_text  varchar2(32767);
    l_result       ut_varchar2_rows;
  begin
    l_cursor_text :=
      q'[select i.object_name
         from ]'||l_ut_owner||q'[.ut_suite_cache_package i
         where
           not exists (
              select 1  from ]'||l_objects_view||q'[ o
               where o.owner = i.object_owner
                 and o.object_name = i.object_name
                 and o.object_type = 'PACKAGE'
                 and o.owner = ']'||a_object_owner||q'['
              )
          and i.object_owner = ']'||a_object_owner||q'[']';
    open l_rows for l_cursor_text;
    fetch l_rows bulk collect into l_result limit 1000000;
    close l_rows;
    return l_result;
  end;

  function get_cached_suite_data(
    a_object_owner   varchar2,
    a_path           varchar2 := null,
    a_object_name    varchar2 := null,
    a_procedure_name varchar2 := null,
    a_skip_all_objects  boolean := false
  ) return t_cached_suites_cursor is
    l_path     varchar2( 4000 );
    l_result   sys_refcursor;
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
  begin
    if a_path is null and a_object_name is not null then
      execute immediate 'select min(path)
      from '||l_ut_owner||q'[.ut_suite_cache
     where object_owner = :a_object_owner
           and object_name = :a_object_name
           and name = nvl(:a_procedure_name, name)]'
      into l_path using upper(a_object_owner), upper(a_object_name), upper(a_procedure_name);
    else
      l_path := lower( a_path );
    end if;

    open l_result for
    q'[with
      suite_items as (
        select /*+ cardinality(c 100) */ c.*
          from ]'||l_ut_owner||q'[.ut_suite_cache c
         where 1 = 1 ]'||case when not a_skip_all_objects then q'[
               and exists
                   ( select 1
                       from all_objects a
                      where a.object_name = c.object_name
                        and a.owner       = ']'||upper(a_object_owner)||q'['
                        and a.owner       = c.object_owner
                        and a.object_type = 'PACKAGE'
                   )]' end ||q'[
               and c.object_owner = ']'||upper(a_object_owner)||q'['
               and ( ]' || case when l_path is not null then q'[
                      :l_path||'.' like c.path || '.%' /*all children and self*/
                     or ( c.path||'.' like :l_path || '.%'  --all parents
                            ]'
                           else ' :l_path is null  and ( :l_path is null ' end
      || case when a_object_name is not null
      then 'and c.object_name = :a_object_name '
         else 'and :a_object_name is null' end ||'
                            '|| case when a_procedure_name is not null
      then 'and c.name = :a_procedure_name'
                                else 'and :a_procedure_name is null' end ||q'[
                        )
                   )
      ),
      suitepaths as (
        select distinct substr(path,1,instr(path,'.',-1)-1) as suitepath,
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
      logical_suite_data as (
        select 'UT_LOGICAL_SUITE' as self_type, p.path, p.object_owner,
               upper( substr(p.path, instr( p.path, '.', -1 ) + 1 ) ) as object_name,
               cast(null as ]'||l_ut_owner||q'[.ut_executables) as x,
               cast(null as ]'||l_ut_owner||q'[.ut_integer_list) as y,
               cast(null as ]'||l_ut_owner||q'[.ut_executable_test) as z
          from suitepath_part p
         where p.path
           not in (select s.path from suitepaths s)
      ),
      logical_suites as (
        select to_number(null) as id, s.self_type, s.path, s.object_owner, s.object_name,
               s.object_name as name, null as line_no, null as parse_time,
               null as description, null as rollback_type, 0 as disabled_flag,
               ]'||l_ut_owner||q'[.ut_varchar2_rows() as warnings,
               s.x as before_all_list, s.x as after_all_list,
               s.x as before_each_list, s.x as before_test_list,
               s.x as after_each_list, s.x as after_test_list,
               s.y as expected_error_codes, s.z as item
          from logical_suite_data s
      ),
      items as (
        select * from suite_items
        union all
        select * from logical_suites
      )
    select c.*
      from items c
     order by c.object_owner,
              replace(case
                      when c.self_type in ( 'UT_TEST' )
                        then substr(c.path, 1, instr(c.path, '.', -1) )
                      else c.path
                      end, '.', chr(0)) desc nulls last,
              c.object_name desc,
              c.line_no]'
    using l_path, l_path, upper(a_object_name), upper(a_procedure_name);

    return l_result;
  end;

  function can_skip_all_objects_scan(
    a_owner_name         varchar2
  ) return boolean is
  begin
    return sys_context( 'userenv', 'current_schema' ) = a_owner_name or ut_metadata.is_object_visible( ut_utils.ut_owner ||'.ut_utils' );
  end;

  procedure build_and_cache_suites(
    a_owner_name        varchar2,
    a_annotated_objects sys_refcursor
  ) is
    l_annotated_objects  ut_annotated_objects;
    l_suite_items        ut_suite_items;
  begin
    loop
      fetch a_annotated_objects bulk collect into l_annotated_objects limit 10;

      for i in 1 .. l_annotated_objects.count loop
        ut_suite_builder.create_suite_item_list( l_annotated_objects( i ), l_suite_items );
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

  end;

  procedure refresh_cache(
    a_owner_name         varchar2,
    a_annotations_cursor sys_refcursor := null
  ) is
    l_annotations_cursor    sys_refcursor;
    l_suite_cache_time      timestamp;
  begin
    l_suite_cache_time := ut_suite_cache_manager.get_schema_parse_time(a_owner_name);
    if a_annotations_cursor is not null then
      l_annotations_cursor := a_annotations_cursor;
    else
      open l_annotations_cursor for
      q'[select value(x)
      from table(
        ]' || ut_utils.ut_owner || q'[.ut_annotation_manager.get_annotated_objects(
              :a_owner_name, 'PACKAGE', :a_suite_cache_parse_time
            )
          )x ]'
      using a_owner_name, l_suite_cache_time;
    end if;

    build_and_cache_suites(a_owner_name, l_annotations_cursor);

    if can_skip_all_objects_scan(a_owner_name) or ut_metadata.is_object_visible( 'dba_objects') then
      ut_suite_cache_manager.remove_from_cache( a_owner_name, get_missing_objects(a_owner_name) );
    end if;

  end;

  procedure add_suites_for_path(
    a_owner_name     varchar2,
    a_path           varchar2 := null,
    a_object_name    varchar2 := null,
    a_procedure_name varchar2 := null,
    a_suites         in out nocopy ut_suite_items
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
        can_skip_all_objects_scan(a_owner_name)
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
        a_skip_all_objects
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
    if ut_metadata.is_object_visible('ut3.ut_utils')
      or (a_schema_names is not null and a_schema_names.count = 1
      and sys_context('userenv','current_schema') = a_schema_names(1))
    then
      l_need_all_objects_scan := false;
    end if;

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

  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items is
    l_suites             ut_suite_items := ut_suite_items();
  begin
    configure_execution_by_path(a_paths, l_suites );
    return l_suites;
  end;

  procedure configure_execution_by_path(a_paths in ut_varchar2_list, a_suites out nocopy ut_suite_items) is
    l_paths              ut_varchar2_list := a_paths;
    l_path_items         t_path_items;
    l_path_item          t_path_item;
    l_schema             varchar2(4000);
    l_suites_count       pls_integer := 0;
    l_index              varchar2(4000 char);
    l_schema_paths       t_schema_paths;
  begin
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
            a_suites
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

  end configure_execution_by_path;

  function get_suites_info(a_owner_name varchar2, a_package_name varchar2) return sys_refcursor is
    l_result      sys_refcursor;
    l_ut_owner    varchar2(250) := ut_utils.ut_owner;
  begin

    refresh_cache(a_owner_name);
    
    open l_result for
    q'[with
      suite_items as (
        select /*+ cardinality(c 100) */ c.*
          from ]'||l_ut_owner||q'[.ut_suite_cache c
         where 1 = 1 ]'||case when can_skip_all_objects_scan(a_owner_name) then q'[
               and exists
                   ( select 1
                       from all_objects a
                      where a.object_name = c.object_name
                        and a.owner       = ']'||upper(a_owner_name)||q'['
                        and a.owner       = c.object_owner
                        and a.object_type = 'PACKAGE'
                   )]' end ||q'[
               and c.object_owner = ']'||upper(a_owner_name) ||q'['
               and ]'
               || case when a_package_name is not null
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
               path, disabled_flag
          from suite_items
        union all
        select object_owner, object_name, object_name as item_name,
               null as item_description, item_type, null as item_line_no,
               s.path,  0 as disabled_flag
          from logical_suites s
      )
    select ]'||l_ut_owner||q'[.ut_suite_item_info(
             object_owner, object_name, item_name, item_description,
             item_type, item_line_no, path, disabled_flag
           )
      from items c]' using upper(a_package_name);

    return l_result;
  end;

end ut_suite_manager;
/
