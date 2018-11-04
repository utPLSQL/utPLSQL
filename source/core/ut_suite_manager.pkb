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

  ------------------

  function get_schema_ut_packages(a_schema_names ut_varchar2_rows) return ut_object_names is
  begin
    return ut_suite_builder.get_schema_ut_packages(a_schema_names);
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

  function get_schema_names(a_paths ut_varchar2_list) return ut_varchar2_rows is
    l_paths ut_varchar2_list;
  begin
    l_paths := a_paths;
    return resolve_schema_names(l_paths);
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
  
  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items is
    l_paths              ut_varchar2_list := a_paths;
    l_path_items         t_path_items;
    l_path_item          t_path_item;
    l_schema             varchar2(4000);
    l_suites             ut_suite_items;
    l_index              varchar2(4000 char);
    l_objects_to_run     ut_suite_items;
    l_schema_paths       t_schema_paths;
  begin
    --resolve schema names from paths and group paths by schema name
    resolve_schema_names(l_paths);

    l_schema_paths := group_paths_by_schema(l_paths);

    l_objects_to_run := ut_suite_items();

    l_schema := l_schema_paths.first;
    while l_schema is not null loop
      l_path_items  := l_schema_paths(l_schema);
      for i in 1 .. l_path_items.count loop
        l_path_item := l_path_items(i);
          l_suites := ut_suite_builder.build_schema_suites(
            upper(l_schema),
            l_path_item.suite_path,
            l_path_item.object_name,
            l_path_item.procedure_name
          );
        if l_suites.count = 0 then
          if l_path_item.suite_path is not null then
            raise_application_error(ut_utils.gc_suite_package_not_found,'No suite packages found for path '||l_schema||':'||l_path_item.suite_path|| '.');
          elsif l_path_item.procedure_name is not null then
            raise_application_error(ut_utils.gc_suite_package_not_found,'Suite test '||l_schema||'.'||l_path_item.object_name|| '.'||l_path_item.procedure_name||' does not exist');
          else
            raise_application_error(ut_utils.gc_suite_package_not_found,'Suite package '||l_schema||'.'||l_path_item.object_name|| ' does not exist');
          end if;
        end if;
        l_index := l_suites.first;
        while l_index is not null loop
          l_objects_to_run.extend;
          l_objects_to_run(l_objects_to_run.count) := l_suites(l_index);
          l_index := l_suites.next(l_index);
        end loop;
      end loop;
      l_schema := l_schema_paths.next(l_schema);
    end loop;

    --propagate rollback type to suite items after organizing suites into hierarchy
    for i in 1 .. l_objects_to_run.count loop
      l_objects_to_run(i).set_rollback_type( l_objects_to_run(i).get_rollback_type() );
    end loop;

    return l_objects_to_run;
  end configure_execution_by_path;

end ut_suite_manager;
/
