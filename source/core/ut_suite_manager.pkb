create or replace package body ut_suite_manager is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

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

  subtype tt_schema_suites is ut_suite_builder.tt_schema_suites;
  subtype t_object_suite_path is ut_suite_builder.t_object_suite_path;
  subtype t_schema_suites_info is ut_suite_builder.t_schema_suites_info;

  type t_schema_info is record (changed_at date, obj_cnt integer);

  type t_schema_cache is record(
     schema_suites tt_schema_suites
    ,changed_at    date
    ,obj_cnt       integer
    ,suite_paths   t_object_suite_path
  );
  type tt_schema_suites_list is table of t_schema_cache index by varchar2(128 char);

  g_schema_suites tt_schema_suites_list;


  type t_schema_paths is table of ut_varchar2_list index by varchar2(4000 char);

  ------------------

  function get_schema_info(a_owner_name varchar2) return t_schema_info is
    l_info t_schema_info;
    l_view_name      varchar2(200) := ut_metadata.get_dba_view('dba_objects');
  begin
    execute immediate q'[
    select nvl(max(t.last_ddl_time), date '4999-12-31'), count(*)
      from ]'||l_view_name||q'[ t
     where t.owner = :a_owner_name
       and t.object_type in ('PACKAGE')]'
    into l_info using a_owner_name;
    return l_info;
  end;

  procedure update_cache(a_owner_name varchar2, a_suites_info t_schema_suites_info, a_total_obj_cnt integer) is
  begin
    if a_suites_info.schema_suites.count > 0 then
      g_schema_suites(a_owner_name).schema_suites := a_suites_info.schema_suites;
      g_schema_suites(a_owner_name).changed_at := sysdate;
      g_schema_suites(a_owner_name).obj_cnt := a_total_obj_cnt;
      g_schema_suites(a_owner_name).suite_paths := a_suites_info.suite_paths;
    elsif g_schema_suites.exists(a_owner_name) then
      g_schema_suites.delete(a_owner_name);
    end if;
  end;

  function cache_valid(a_schema_name varchar2) return boolean is
    l_info   t_schema_info;
    l_result boolean := true;
  begin
    if not g_schema_suites.exists(a_schema_name) then
      l_result := false;
    else
      l_info := get_schema_info(a_schema_name);
      if g_schema_suites(a_schema_name).changed_at <= l_info.changed_at or g_schema_suites(a_schema_name).obj_cnt != l_info.obj_cnt then
        l_result := false;
      else
        l_result := true;
      end if;
    end if;
    return l_result;
  end;

  function get_schema_suites(a_schema_name in varchar2) return t_schema_suites_info is
    l_result      t_schema_suites_info;
  begin
    -- Currently cache invalidation on DDL is not implemented so schema is rescaned each time
    if cache_valid(a_schema_name) then
      l_result.schema_suites := g_schema_suites(a_schema_name).schema_suites;
      l_result.suite_paths := g_schema_suites(a_schema_name).suite_paths;
    else
      ut_utils.debug_log('Rescanning schema ' || a_schema_name);
      l_result := ut_suite_builder.build_schema_suites(a_schema_name);
      update_cache(a_schema_name, l_result, get_schema_info(a_schema_name).obj_cnt );
    end if;

    return l_result;
  end get_schema_suites;

  function get_schema_ut_packages(a_schema_names ut_varchar2_rows) return ut_object_names is
    l_schema_ut_packages ut_object_names := ut_object_names();
    l_schema_suites      tt_schema_suites;
    l_iter               varchar2(4000);
    procedure populate_suite_ut_packages(a_suite ut_logical_suite, a_packages in out nocopy ut_object_names) is
      l_sub_suite ut_logical_suite;
    begin
      if a_suite is of (ut_suite) then
        a_packages.extend;
        a_packages(a_packages.last) := ut_object_name(a_suite.object_owner, a_suite.object_name);
      end if;
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of (ut_logical_suite) then
          l_sub_suite := treat(a_suite.items(i) as ut_logical_suite);
          populate_suite_ut_packages(l_sub_suite, a_packages);
        end if;
      end loop;
    end;
  begin
    if a_schema_names is not null then
      for i in 1 .. a_schema_names.count loop
        l_schema_suites := get_schema_suites(a_schema_names(i)).schema_suites;
        l_iter := l_schema_suites.first;
        while l_iter is not null loop
          populate_suite_ut_packages(l_schema_suites(l_iter), l_schema_ut_packages);
          l_iter := l_schema_suites.next(l_iter);
        end loop;
      end loop;
      l_schema_ut_packages := set(l_schema_ut_packages);
    end if;

    return l_schema_ut_packages;
  end;

  procedure resolve_schema_names(a_paths in out nocopy ut_varchar2_list) is
    l_schema          varchar2(4000);
    l_object          varchar2(4000);
    c_current_schema  constant all_tables.owner%type := sys_context('USERENV','CURRENT_SCHEMA');
  begin
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
          l_schema := c_current_schema;
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
    end loop;
  end;

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

  function clean_paths(a_paths ut_varchar2_list) return ut_varchar2_list is
    l_paths_temp ut_varchar2_list := ut_varchar2_list();
  begin
    l_paths_temp.extend(a_paths.count);
    for i in 1 .. a_paths.count loop
      l_paths_temp(i) := trim(lower(a_paths(i)));
    end loop;
    return l_paths_temp;
  end;

  procedure filter_suite_by_path(a_suite in out nocopy ut_suite_item, a_path varchar2) is
    c_root        constant varchar2(32767) := lower(regexp_substr(a_path, '[A-Za-z0-9$#_]+'));
    c_rest_path   constant varchar2(32767) := regexp_substr(a_path, '\.(.+)', subexpression => 1);
    l_suite       ut_logical_suite;
    l_item        ut_suite_item;
    l_items       ut_suite_items := ut_suite_items();
  begin
    if a_path is not null and a_suite is not null and a_suite is of (ut_logical_suite) then
      l_suite := treat(a_suite as ut_logical_suite);

      for i in 1 .. l_suite.items.count loop
        l_item := l_suite.items(i);
        if lower(l_item.name) = c_root then
          filter_suite_by_path(l_item, c_rest_path);
          l_items.extend;
          l_items(l_items.count) := l_item;
        end if;
      end loop;

      if l_items.count = 0 then
        raise_application_error(-20203, 'Suite not found');
      end if;

      l_suite.items := l_items;
      a_suite := l_suite;
    end if;
  end filter_suite_by_path;

  function get_suite_filtered_by_path(a_path varchar2, a_schema_suites tt_schema_suites) return ut_logical_suite is
    l_suite           ut_logical_suite;
    c_suite_path      constant varchar2(4000) := regexp_substr(a_path, ':(.+)', subexpression => 1);
    c_root_suite_name constant varchar2(4000) := regexp_substr(c_suite_path, '^[A-Za-z0-9$#_]+');
  begin
    l_suite := a_schema_suites(c_root_suite_name);
    filter_suite_by_path(l_suite, regexp_substr(c_suite_path, '\.(.+)', subexpression => 1));
    return l_suite;
  exception
    when no_data_found then
      raise_application_error(-20203, 'Suite ' || c_root_suite_name || ' does not exist or is invalid');
  end;

  function convert_to_suite_path(a_path varchar2, a_suite_paths t_object_suite_path) return varchar2 is
    c_package_path_regex constant varchar2(100) := '^([A-Za-z0-9$#_]+)\.([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_]+))?$';
    l_schema_name        varchar2(4000) := regexp_substr(a_path, c_package_path_regex, subexpression => 1);
    l_package_name       varchar2(4000) := regexp_substr(a_path, c_package_path_regex, subexpression => 2);
    l_procedure_name     varchar2(4000) := regexp_substr(a_path, c_package_path_regex, subexpression => 4);
    l_path               varchar2(4000) := a_path;
  begin
    if regexp_like(l_path, c_package_path_regex) then
      if not a_suite_paths.exists(l_package_name) then
        raise_application_error(ut_utils.gc_suite_package_not_found,'Suite package '||l_schema_name||'.'||l_package_name|| ' not found');
      end if;
      l_path := rtrim(l_schema_name || ':' || a_suite_paths(l_package_name) || '.' || l_procedure_name, '.');
    end if;
    return l_path;
  end;

  function group_paths_by_schema(a_paths ut_varchar2_list) return t_schema_paths is
    l_result          t_schema_paths;
    l_schema          varchar2(4000);
  begin
    for i in 1 .. a_paths.count loop
      l_schema := upper(regexp_substr(a_paths(i),'^[^.:]+'));
      if l_result.exists(l_schema) then
        l_result(l_schema).extend;
        l_result(l_schema)(l_result(l_schema).last) := a_paths(i);
      else
        l_result(l_schema) := ut_varchar2_list(a_paths(i));
      end if;
    end loop;
    return l_result;
  end;

  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items is
    l_paths              ut_varchar2_list;
    l_path               varchar2(32767);
    l_schema             varchar2(4000);
    l_suites_info        t_schema_suites_info;
    l_index              varchar2(4000 char);
    l_suite              ut_logical_suite;
    l_objects_to_run     ut_suite_items;
    l_schema_paths   t_schema_paths;
  begin
    l_paths := set( clean_paths(a_paths) );

    validate_paths(l_paths);

    --resolve schema names from paths and group paths by schema name
    resolve_schema_names(l_paths);

    l_schema_paths := group_paths_by_schema(l_paths);

    l_objects_to_run := ut_suite_items();

    l_schema := l_schema_paths.first;
    while l_schema is not null loop
      l_paths := l_schema_paths(l_schema);
      l_suites_info := get_schema_suites(l_schema);

      for i in 1 .. l_paths.count loop
        l_path := l_paths(i);
        --run whole schema
        if regexp_like(l_path, '^[A-Za-z0-9$#_]+$') then
          l_index := l_suites_info.schema_suites.first;
          while l_index is not null loop
            l_objects_to_run.extend;
            l_objects_to_run(l_objects_to_run.count) := l_suites_info.schema_suites(l_index);
            l_index := l_suites_info.schema_suites.next(l_index);
          end loop;
        else
          l_suite := get_suite_filtered_by_path( convert_to_suite_path( l_path, l_suites_info.suite_paths ), l_suites_info.schema_suites );
          l_objects_to_run.extend;
          l_objects_to_run(l_objects_to_run.count) := l_suite;
        end if;
      end loop;
      l_schema := l_schema_paths.next(l_schema);
    end loop;

    return l_objects_to_run;
  end configure_execution_by_path;

end ut_suite_manager;
/
