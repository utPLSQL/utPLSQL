create or replace package body ut_suite_manager is
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

  gc_suitpath_error_message constant varchar2(100) := 'Suitepath exceeds 1000 CHAR on: ';
  cursor c_cached_suites_cursor is select * from table(ut_suite_cache_rows());
  type tt_cached_suites         is table of c_cached_suites_cursor%rowtype;
  type t_cached_suites_cursor   is ref cursor return c_cached_suites_cursor%rowtype;
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
        if l_path is null or not (
          regexp_like(l_path, '^[A-Za-z0-9$#_\*]+(\.[A-Za-z0-9$#_\*]+){0,2}$') or regexp_like(l_path, '^([A-Za-z0-9$#_]+)?:[A-Za-z0-9$#_\*]+(\.[A-Za-z0-9$#_\*]+)*$')) then
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
        -- Object name or procedure is allowed to have filter char
        -- However this is not allowed on schema
        begin
          l_object := regexp_substr(a_paths(i), '^[A-Za-z0-9$#_\*]+');
          l_schema := sys.dbms_assert.schema_name(upper(l_object));
        exception
          when sys.dbms_assert.invalid_schema_name then
            if l_object like '%*%' or ut_metadata.package_exists_in_cur_schema(upper(l_object)) then
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
                  rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
                  rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
                rollback_type => a_rows( a_idx ).rollback_type, disabled_flag => a_rows( a_idx ).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
              rollback_type => a_rows(a_idx).rollback_type, disabled_flag => a_rows(a_idx).disabled_flag, disabled_reason  => a_rows(a_idx).disabled_reason,
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
  
  function get_filtered_cursor(
    a_unfiltered_rows in ut_suite_cache_rows,
    a_skip_all_objects boolean  := false
  ) 
  return ut_suite_cache_rows is
    l_result           ut_suite_cache_rows := ut_suite_cache_rows();
  begin
    if ut_metadata.user_has_execute_any_proc() or a_skip_all_objects then
      l_result := a_unfiltered_rows;
    else
      select obj bulk collect into l_result
      from (
        select /*+ no_parallel */  value(c) as obj from table(a_unfiltered_rows) c
          where sys_context( 'userenv', 'current_user' ) = upper(c.object_owner)
        union all
        select /*+ no_parallel */ value(c) as obj from table(a_unfiltered_rows) c
          where sys_context( 'userenv', 'current_user' ) != upper(c.object_owner)
          and ( exists
           ( select 1
               from all_objects a
               where a.object_name = c.object_name
               and a.owner       = c.object_owner
               and a.object_type = 'PACKAGE'
            )
          or c.self_type = 'UT_LOGICAL_SUITE'));
    end if; 
    return l_result;
  end;
  
  procedure reconcile_paths_and_suites(
    a_schema_paths     ut_path_items,
    a_filtered_rows    ut_suite_cache_rows
  ) is
  begin 
    for i in ( select  /*+ no_parallel */ sp.schema_name,sp.object_name,sp.procedure_name,
        sp.suite_path,sc.path
      from table(a_schema_paths) sp left outer join
      table(a_filtered_rows) sc on 
        (( upper(sp.schema_name) = upper(sc.object_owner) and upper(sp.object_name) = upper(sc.object_name) 
           and nvl(upper(sp.procedure_name),sc.name) = sc.name )
        or (sc.path = sp.suite_path))          
        where sc.path is null)
    loop
      if i.suite_path is not null then
        raise_application_error(ut_utils.gc_suite_package_not_found,'No suite packages found for path '||i.schema_name||':'||i.suite_path|| '.');
      elsif i.procedure_name is not null then
        raise_application_error(ut_utils.gc_suite_package_not_found,'Suite test '||i.schema_name||'.'||i.object_name|| '.'||i.procedure_name||' does not exist');
      elsif i.object_name is not null then
        raise_application_error(ut_utils.gc_suite_package_not_found,'Suite package '||i.schema_name||'.'||i.object_name|| ' does not exist');
      end if;
    end loop;    
  end;
  
  function get_cached_suite_data(
    a_schema_paths     ut_path_items,
    a_random_seed      positive,
    a_tags             ut_varchar2_rows := null,
    a_skip_all_objects boolean  := false
  ) return t_cached_suites_cursor is
    l_unfiltered_rows  ut_suite_cache_rows;
    l_filtered_rows    ut_suite_cache_rows;
    l_result           t_cached_suites_cursor;
  begin
    l_unfiltered_rows := ut_suite_cache_manager.get_cached_suite_rows(
      a_schema_paths,
      a_random_seed,
      a_tags
    );  
    
    l_filtered_rows := get_filtered_cursor(l_unfiltered_rows,a_skip_all_objects);
    reconcile_paths_and_suites(a_schema_paths,l_filtered_rows);
    
    ut_suite_cache_manager.sort_and_randomize_tests(l_filtered_rows,a_random_seed);

    open l_result for 
      select * from table(l_filtered_rows);
    return l_result;
  end;

  function can_skip_all_objects_scan(
    a_owner_name         varchar2
  ) return boolean is
  begin
    return sys_context( 'userenv', 'current_user' ) = upper(a_owner_name) or ut_metadata.user_has_execute_any_proc();
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
    l_owner_name            varchar2(128) := upper(a_owner_name);
  begin
    ut_event_manager.trigger_event('refresh_cache - start');
    l_suite_cache_time := ut_suite_cache_manager.get_schema_parse_time(l_owner_name);
    l_annotations_cursor := ut_annotation_manager.get_annotated_objects(
      l_owner_name, 'PACKAGE', l_suite_cache_time
    );

    build_and_cache_suites(l_owner_name, l_annotations_cursor);

    if can_skip_all_objects_scan(l_owner_name) or ut_metadata.is_object_visible( 'dba_objects') then
      ut_suite_cache_manager.remove_missing_objs_from_cache( l_owner_name );
    end if;

    ut_event_manager.trigger_event('refresh_cache - end');
  end;

  procedure add_suites_for_paths(
    a_schema_paths   ut_path_items,
    a_suites         in out nocopy ut_suite_items,
    a_random_seed    positive,
    a_tags           ut_varchar2_rows := null
  ) is
  begin
    reconstruct_from_cache(
      a_suites,
      get_cached_suite_data(
        a_schema_paths,
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
    l_schema_paths       ut_path_items;
  begin
    build_and_cache_suites(a_owner_name, a_annotated_objects);
    l_schema_paths := ut_path_items(ut_path_item(a_owner_name,a_object_name,a_procedure_name,a_path));
    reconstruct_from_cache(
      l_suites,
      get_cached_suite_data(
        l_schema_paths,
        null,
        null,        
        a_skip_all_objects
      )
    );
    return l_suites;
  end;

  function get_schema_ut_packages(a_schema_names ut_varchar2_rows) return ut_object_names is
  begin
    for i in 1 .. a_schema_names.count loop
      refresh_cache(a_schema_names(i));
    end loop;

    return ut_suite_cache_manager.get_cached_packages( a_schema_names );
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
    l_schema_names       ut_varchar2_rows;
    l_schema_paths       ut_path_items;
    l_schema             varchar2(4000);
  begin
    ut_event_manager.trigger_event('configure_execution_by_path - start');
    a_suites := ut_suite_items();    
    --resolve schema names from paths and group paths by schema name
    l_schema_names := resolve_schema_names(l_paths);

    --refresh cache
    l_schema := l_schema_names.first;
    while l_schema is not null loop
      refresh_cache(upper(l_schema_names(l_schema)));
      l_schema := l_schema_names.next(l_schema);
    end loop;
    
    l_schema_paths := ut_suite_cache_manager.get_schema_paths(l_paths);
    
    --We will get a single list of paths rather than loop by loop.
    add_suites_for_paths(
      l_schema_paths,
      a_suites,
      a_random_seed,
      a_tags
    );
        
    --propagate rollback type to suite items after organizing suites into hierarchy
    for i in 1 .. a_suites.count loop
      a_suites(i).set_rollback_type( a_suites(i).get_rollback_type() );
    end loop;

    ut_event_manager.trigger_event('configure_execution_by_path - start');
  end configure_execution_by_path;

  function get_suites_info(
    a_paths     ut_varchar2_list
  ) return sys_refcursor is
    l_result             sys_refcursor;
    l_all_suite_info     ut_suite_items_info;
    l_schema_names       ut_varchar2_rows;
    l_schema_paths       ut_path_items;
    l_paths              ut_varchar2_list := a_paths; 
    l_schema             varchar2(4000);
    l_unfiltered_rows    ut_suite_cache_rows;
    l_filtered_rows      ut_suite_cache_rows;
   
  begin
    l_schema_names := resolve_schema_names(l_paths);
    --refresh cache
    l_schema := l_schema_names.first;
    while l_schema is not null loop
      refresh_cache(upper(l_schema_names(l_schema)));
      l_schema := l_schema_names.next(l_schema);
    end loop;
    l_schema_paths := ut_suite_cache_manager.get_schema_paths(l_paths);
    l_unfiltered_rows := ut_suite_cache_manager.get_cached_suite_info(l_schema_paths);
    l_filtered_rows := get_filtered_cursor(l_unfiltered_rows);
    l_all_suite_info := ut_suite_cache_manager.get_suite_items_info(l_filtered_rows);
    open l_result for
      select /*+ no_parallel */ value(c)
        from table(l_all_suite_info) c
        order by c.object_owner, c.object_name, c.item_line_no;

    return l_result;
  end;

  function suite_item_exists(
    a_owner_name     varchar2, 
    a_package_name   varchar2 := null, 
    a_procedure_name varchar2 := null
  ) return boolean is
    l_count          integer := 1;
    l_item_exists    boolean;
    l_owner_name     varchar2(250) := upper(a_owner_name);
    l_package_name   varchar2(250) := upper(a_package_name);
    l_procedure_name varchar2(250) := upper(a_procedure_name);
  begin

    refresh_cache(l_owner_name);
    l_item_exists := ut_suite_cache_manager.suite_item_exists( l_owner_name, l_package_name, l_procedure_name );
    if not can_skip_all_objects_scan( l_owner_name ) and l_package_name is not null then
      select /*+ no_parallel */ count(1)
        into l_count
        from dual c
       where exists
         ( select 1
             from all_objects a
            where a.object_name = l_package_name
              and a.owner       = l_owner_name
              and a.object_type = 'PACKAGE'
         );
    end if;

    return l_count > 0 and l_item_exists;
  end;

end ut_suite_manager;
/
