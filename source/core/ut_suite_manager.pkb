create or replace package body ut_suite_manager is
  /*
  utPLSQL - Version X.X.X.X
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

  type t_schema_info is record (changed_at date, obj_cnt integer);

  type tt_schema_suites is table of ut_logical_suite index by varchar2(4000 char);
  type t_schema_cache is record(
     schema_suites tt_schema_suites
    ,changed_at    date
    ,obj_cnt integer);
  type tt_schema_suites_list is table of t_schema_cache index by varchar2(128 char);

  g_schema_suites tt_schema_suites_list;

  type t_object_suite_path is table of varchar2(4000) index by varchar2(4000 char);
  type t_schema_suite_paths is table of t_object_suite_path index by varchar2(250);

  g_schema_object_path_map t_schema_suite_paths;

  ------------------

  function trim_path(a_path varchar2, a_part varchar2) return varchar2 is
  begin
    return substr(a_path, nvl(length(a_part), 0) + 1);
  end;

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

  function config_package(a_object ut_annotated_object) return ut_logical_suite is
    l_is_suite           boolean := false;
    l_is_test            boolean := false;
    l_suite_disabled     boolean := false;
    l_test_disabled      boolean := false;
    l_suite_items        ut_suite_items := ut_suite_items();
    l_suite_name         ut_annotation_parser.t_annotation_name;

    l_default_setup_proc    varchar2(250 char);
    l_default_teardown_proc varchar2(250 char);
    l_suite_setup_proc      varchar2(250 char);
    l_suite_teardown_proc   varchar2(250 char);
    l_suite_path            varchar2(4000 char);

    l_proc_name   ut_annotation_parser.t_procedure_name;

    l_suite       ut_logical_suite;
    l_test        ut_test;

    l_suite_rollback            integer;

    l_beforetest_procedure varchar2(250 char);
    l_aftertest_procedure  varchar2(250 char);
    l_rollback_type        integer;
    l_displayname          varchar2(4000);

    e_insufficient_priv         exception;
    pragma exception_init(e_insufficient_priv,-01031);
  begin
    l_suite_rollback := ut_utils.gc_rollback_auto;
    for i in 1 .. a_object.annotations.count loop

      if a_object.annotations(i).subobject_name is null then

        if a_object.annotations(i).name in ('suite','displayname') then
          l_suite_name := a_object.annotations(i).text;
          if a_object.annotations(i).name = 'suite' then
            l_is_suite := true;
          end if;
        elsif a_object.annotations(i).name = 'disabled' then
          l_suite_disabled := true;
        elsif a_object.annotations(i).name = 'suitepath' and  a_object.annotations(i).text is not null then
          l_suite_path := a_object.annotations(i).text || '.' || lower(a_object.object_name);
        elsif a_object.annotations(i).name = 'rollback' then
          if lower(a_object.annotations(i).text) = 'manual' then
            l_suite_rollback := ut_utils.gc_rollback_manual;
          else
            l_suite_rollback := ut_utils.gc_rollback_auto;
          end if;
        end if;

      elsif l_is_suite then

        l_proc_name := a_object.annotations(i).subobject_name;

        if a_object.annotations(i).name = 'beforeeach' and l_default_setup_proc is null then
          l_default_setup_proc := l_proc_name;
        elsif a_object.annotations(i).name = 'aftereach' and l_default_teardown_proc is null then
          l_default_teardown_proc := l_proc_name;
        elsif a_object.annotations(i).name = 'beforeall' and l_suite_setup_proc is null then
          l_suite_setup_proc := l_proc_name;
        elsif a_object.annotations(i).name = 'afterall' and l_suite_teardown_proc is null then
          l_suite_teardown_proc := l_proc_name;


        elsif a_object.annotations(i).name = 'disabled' then
          l_test_disabled := true;
        elsif a_object.annotations(i).name = 'beforetest' then
          l_beforetest_procedure := a_object.annotations(i).text;
        elsif a_object.annotations(i).name = 'aftertest' then
          l_aftertest_procedure := a_object.annotations(i).text;
        elsif a_object.annotations(i).name in ('displayname','test') then
          l_displayname := a_object.annotations(i).text;
          if a_object.annotations(i).name = 'test' then
            l_is_test := true;
          end if;
        elsif a_object.annotations(i).name = 'rollback' then
          if lower(a_object.annotations(i).text) = 'manual' then
            l_rollback_type := ut_utils.gc_rollback_manual;
          elsif lower(a_object.annotations(i).text) = 'auto' then
            l_rollback_type := ut_utils.gc_rollback_auto;
          end if;
        end if;

        if l_is_test
           and (i = a_object.annotations.count
                or l_proc_name != nvl(a_object.annotations(i+1).subobject_name, ' ') ) then
          l_suite_items.extend;
          l_suite_items(l_suite_items.last) :=
            ut_test(a_object_owner          => a_object.object_owner
                   ,a_object_name           => a_object.object_name
                   ,a_name                  => l_proc_name
                   ,a_description           => l_displayname
                   ,a_rollback_type         => coalesce(l_rollback_type, l_suite_rollback)
                   ,a_disabled_flag         => l_suite_disabled or l_test_disabled
                   ,a_before_test_proc_name => l_beforetest_procedure
                   ,a_after_test_proc_name  => l_aftertest_procedure);

          l_is_test := false;
          l_test_disabled := false;
          l_aftertest_procedure  := null;
          l_beforetest_procedure := null;
          l_rollback_type        := null;
        end if;

      end if;
    end loop;

    if l_is_suite then
      l_suite := ut_suite (
          a_object_owner          => a_object.object_owner,
          a_object_name           => a_object.object_name,
          a_name                  => a_object.object_name, --this could be different for sub-suite (context)
          a_path                  => l_suite_path,  --a patch for this suite (excluding the package name of current suite)
          a_description           => l_suite_name,
          a_rollback_type         => l_suite_rollback,
          a_disabled_flag         => l_suite_disabled,
          a_before_all_proc_name  => l_suite_setup_proc,
          a_after_all_proc_name   => l_suite_teardown_proc
      );
      for i in 1 .. l_suite_items.count loop
        l_test := treat(l_suite_items(i) as ut_test);
        l_test.set_beforeeach(l_default_setup_proc);
        l_test.set_aftereach(l_default_teardown_proc);
        l_test.path := l_suite.path  || '.' ||  l_test.name;
        l_suite.add_item(l_test);
      end loop;
    end if;

    return l_suite;

  end config_package;

  function build_suites(a_cursor sys_refcursor) return ut_suite_items pipelined is
    l_object ut_annotated_object;
  begin
    loop
      fetch a_cursor into l_object;
      exit when a_cursor%notfound;
      pipe row (config_package(l_object));
    end loop;
    close a_cursor;
    return;
  end;

  procedure update_cache(a_owner_name varchar2, a_schema_suites tt_schema_suites, a_total_obj_cnt integer) is
  begin
    if a_schema_suites.count > 0 then
      g_schema_suites(a_owner_name).schema_suites := a_schema_suites;
      g_schema_suites(a_owner_name).changed_at := sysdate;
      g_schema_suites(a_owner_name).obj_cnt := a_total_obj_cnt;
    elsif g_schema_suites.exists(a_owner_name) then
      g_schema_suites.delete(a_owner_name);
    end if;
  end;

  procedure config_schema(a_owner_name varchar2) is
    l_suite      ut_logical_suite;

    l_all_suites tt_schema_suites;
    l_ind        varchar2(4000 char);
    l_path       varchar2(4000 char);
    l_root       varchar2(4000 char);
    l_root_suite ut_logical_suite;

    type t_object_name is record(
      owner all_objects.owner%type,
      object_name all_objects.object_name%type
    );
    type t_object_names is table of t_object_name;

    l_object_names t_object_names;
    l_view_name      varchar2(200) := ut_metadata.get_dba_view('dba_objects');

    l_schema_suites tt_schema_suites;

    procedure put(a_root_suite in out nocopy ut_logical_suite, a_path varchar2, a_suite ut_logical_suite, a_parent_path varchar2 default null) is
      l_temp_root varchar2(4000 char);
      l_path      varchar2(4000 char);
      l_cur_item  ut_logical_suite;
      l_ind       pls_integer;
    begin
      if a_path like '%.%' then
        l_temp_root := regexp_substr(a_path, '^[^.]+');
        l_path      := ltrim(a_parent_path || '.' || l_temp_root, '.');

        if a_root_suite is not null then

          l_ind := a_root_suite.item_index(l_temp_root);

          if l_ind is null then
            --this only happens when a path of a real suite contains a parent-suite that is not a real package.
            l_cur_item := ut_logical_suite(a_object_owner => a_owner_name, a_object_name => l_temp_root, a_name => l_temp_root, a_path => l_path);
          else
            l_cur_item := treat(a_root_suite.items(l_ind) as ut_logical_suite);
          end if;

          put(l_cur_item, trim_path(a_path, l_temp_root || '.'), a_suite, l_path);

          if l_ind is null then
            a_root_suite.add_item(l_cur_item);
          else
            a_root_suite.items(l_ind) := l_cur_item;
          end if;

        else
          a_root_suite := ut_logical_suite(a_object_owner => a_owner_name, a_object_name => l_temp_root, a_name => l_temp_root, a_path => l_path);
          put(a_root_suite, trim_path(a_path, l_temp_root || '.'), a_suite, l_path);
        end if;
      else
        if a_root_suite is not null then
          a_root_suite.add_item(a_suite);
        else
          a_root_suite := a_suite;
        end if;
      end if;
    end;

    $if $$ut_trace $then
    procedure print(a_item ut_suite_item, a_pad pls_integer) is
      l_suite ut_logical_suite;
      l_pad   varchar2(1000) := lpad(' ', a_pad, ' ');
    begin
      if a_item is of (ut_logical_suite) then
        dbms_output.put_line(l_pad || 'Suite: ' || a_item.name || '(' || a_item.path || ')');
        dbms_output.put_line(l_pad || 'Items: ');
        l_suite := treat(a_item as ut_logical_suite);
        for i in 1 .. l_suite.items.count loop
          print(l_suite.items(i), a_pad + 2);
        end loop;
      else
        dbms_output.put_line(l_pad || 'Test: ' || a_item.name || '(' || a_item.path || ')' );
      end if;
    end print;
    $end

  begin
    g_schema_object_path_map.delete(a_owner_name);
    -- form the single-dimension list of suites constructed from parsed packages
    for i in (
      select treat(value(t) as ut3.ut_logical_suite) suite
        from table(
          ut3.ut_suite_manager.build_suites(
            cursor( select value(x) from table (ut3.ut_annotation_parser.get_annotated_objects(a_owner_name, 'PACKAGE'))x )
          )
        ) t
    ) loop
      if i.suite is not null then
        l_all_suites(i.suite.path) := i.suite;
        g_schema_object_path_map(a_owner_name)(i.suite.object_name) := i.suite.path;
      end if;
    end loop;

    --build hierarchical structure of the suite
    l_schema_suites.delete;

    -- Restructure single-dimenstion list into hierarchy of suites by the value of %suitepath attribute value
    -- All root suite compose the root-suite list of the schema
    l_ind := l_all_suites.first;
    while l_ind is not null loop

      l_root := regexp_substr(l_ind, '^[^.]+');

      if l_schema_suites.exists(l_root) then
        l_root_suite := l_schema_suites(l_root);
        l_path       := trim_path(l_ind, l_root || '.');
      else
        l_root_suite := null;
        l_path       := l_ind;
      end if;
      put(l_root_suite, l_path, l_all_suites(l_ind));

      l_schema_suites(l_root) := l_root_suite;

      l_ind := l_all_suites.next(l_ind);
    end loop;

    -- Caching
    update_cache(a_owner_name, l_schema_suites, get_schema_info(a_owner_name).obj_cnt );

    -- printing results for debugging purpose
    $if $$ut_trace $then
    l_ind := l_schema_suites.first;
    while l_ind is not null loop
      print(l_schema_suites(l_ind), 0);
      l_ind := l_schema_suites.next(l_ind);
    end loop;
    $end

  end config_schema;

  function get_schema_suites(a_schema_name in varchar2) return tt_schema_suites is
    l_schema_info t_schema_info;
  begin
    -- Currently cache invalidation on DDL is not implemented so schema is rescaned each time
    l_schema_info := get_schema_info(a_schema_name);
    if not g_schema_suites.exists(a_schema_name) or g_schema_suites(a_schema_name).changed_at <= l_schema_info.changed_at or
       g_schema_suites(a_schema_name).obj_cnt != l_schema_info.obj_cnt then
      ut_utils.debug_log('Rescanning schema ' || a_schema_name);
      config_schema(a_schema_name);
    end if;

    if g_schema_suites.exists(a_schema_name) then
      return g_schema_suites(a_schema_name).schema_suites;
    else
      return cast(null as tt_schema_suites);
    end if;
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
        l_schema_suites := get_schema_suites(a_schema_names(i));
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

  -- Validate all paths are correctly formatted
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
  end validate_paths;

  function configure_execution_by_path(a_paths in ut_varchar2_list) return ut_suite_items is
    l_paths           ut_varchar2_list;
    l_path            varchar2(32767);
    l_schema          varchar2(4000);
    l_schema_suites   tt_schema_suites;
    l_index           varchar2(4000 char);
    l_suite           ut_logical_suite;
    l_suite_path      varchar2(4000);
    l_root_suite_name varchar2(4000);
    l_objects_to_run  ut_suite_items;
    c_current_schema  constant all_tables.owner%type := sys_context('USERENV','CURRENT_SCHEMA');

    function clean_paths(a_paths ut_varchar2_list) return ut_varchar2_list is
      l_paths_temp ut_varchar2_list := ut_varchar2_list();
    begin
      l_paths_temp.extend(a_paths.count);
      for i in 1 .. a_paths.count loop
        l_paths_temp(i) := trim(lower(a_paths(i)));
      end loop;
      l_paths_temp := set(l_paths_temp);
      return l_paths_temp;
    end clean_paths;

    procedure skip_by_path(a_suite in out nocopy ut_suite_item, a_path varchar2) is
      c_root        constant varchar2(32767) := upper(regexp_substr(a_path, '[A-Za-z0-9$#_]+'));
      c_rest_path   constant varchar2(32767) := regexp_substr(a_path, '\.(.+)', subexpression => 1);
      l_suite       ut_logical_suite;
      l_item        ut_suite_item;
      l_items       ut_suite_items := ut_suite_items();
    begin
      if a_path is not null and a_suite is not null and a_suite is of (ut_logical_suite) then
        l_suite := treat(a_suite as ut_logical_suite);

        for i in 1 .. l_suite.items.count loop

          l_item := l_suite.items(i);

          if upper(l_item.name) = c_root then

            skip_by_path(l_item, c_rest_path);
            l_items.extend;
            l_items(l_items.count) := l_item;

          end if;

        end loop;

        if l_items.count = 0 then
          --not l_found then
          raise_application_error(-20203, 'Suite not found');
        end if;

        l_suite.items := l_items;
        a_suite := l_suite;

      end if;
    end skip_by_path;

    function package_exists_in_cur_schema(a_package_name varchar2) return boolean is
      l_cnt number;
    begin
      select count(*)
        into l_cnt
        from all_objects t
       where t.object_name = upper(a_package_name)
         and t.object_type = 'PACKAGE'
         and t.owner = c_current_schema;
      return l_cnt > 0;
    end package_exists_in_cur_schema;

  begin
    l_paths := clean_paths(a_paths);

    validate_paths(l_paths);
    l_objects_to_run := ut_suite_items();

    -- current implementation operates only on a single path
    -- to be improved later
    for i in 1 .. l_paths.count loop
      l_path   := l_paths(i);
      if regexp_like(l_path, '^([A-Za-z0-9$#_]+)?:') then
        l_schema := regexp_substr(l_path, '^([A-Za-z0-9$#_]+)?:',subexpression => 1);
        -- transform ":path1[.path2]" to "schema:path1[.path2]"
        if l_schema is not null then
          l_schema := sys.dbms_assert.schema_name(upper(l_schema));
        else
          l_path   := c_current_schema || l_path;
          l_schema := c_current_schema;
        end if;
      else
        -- When path is one of: schema or schema.package[.object] or package[.object]
        -- transform it back to schema[.package[.object]]
        begin
          l_schema := regexp_substr(l_path, '^[A-Za-z0-9$#_]+');
          l_schema := sys.dbms_assert.schema_name(upper(l_schema));
        exception
          when sys.dbms_assert.invalid_schema_name then
            if package_exists_in_cur_schema(l_schema) then
              l_path := c_current_schema || '.' || l_path;
              l_schema := c_current_schema;
            else
              raise;
            end if;
        end;

      end if;

      l_schema_suites := get_schema_suites(upper(l_schema));

      if regexp_like(l_path, '^[A-Za-z0-9$#_]+$') then
        -- run whole schema
        l_index := l_schema_suites.first;
        while l_index is not null loop
          l_objects_to_run.extend;
          l_objects_to_run(l_objects_to_run.count) := l_schema_suites(l_index);
          l_index := l_schema_suites.next(l_index);
        end loop;
      else
        -- convert SCHEMA.PACKAGE.PROCEDURE syntax to fully qualified path
        if regexp_like(l_path, '^[A-Za-z0-9$#_]+(\.[A-Za-z0-9$#_]+){1,2}$') then
          declare
            l_temp_suite     ut_logical_suite;
            l_package_name   varchar2(4000);
            l_procedure_name varchar2(4000);
          begin
            l_package_name   := regexp_substr(l_path, '^[A-Za-z0-9$#_]+\.([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_]+))?$', subexpression => 1);
            l_procedure_name := regexp_substr(l_path, '^[A-Za-z0-9$#_]+\.([A-Za-z0-9$#_]+)(\.([A-Za-z0-9$#_]+))?$', subexpression => 3);

            if not g_schema_object_path_map(l_schema).exists(l_package_name) then
              raise_application_error(ut_utils.gc_suite_package_not_found,'Suite package '||l_schema||'.'||l_package_name|| ' not found');
            end if;
            l_path       := rtrim(l_schema || ':' || g_schema_object_path_map(l_schema)(l_package_name) || '.' || l_procedure_name, '.');
          end;
        end if;

        -- fully qualified path branch in the form
        -- by this time it's the only format left
        -- schema:suite.suite.suite
        l_suite_path      := regexp_substr(l_path, ':(.+)', subexpression => 1);
        l_root_suite_name := regexp_substr(l_suite_path, '^[A-Za-z0-9$#_]+');

        begin
          l_suite := l_schema_suites(l_root_suite_name);
        exception
          when no_data_found then
            raise_application_error(-20203, 'Suite ' || l_root_suite_name || ' does not exist or is invalid');
        end;

        skip_by_path(l_suite, regexp_substr(l_suite_path, '\.(.+)', subexpression => 1));

        l_objects_to_run.extend;
        l_objects_to_run(l_objects_to_run.count) := l_suite;

      end if;

    end loop;
    return l_objects_to_run;
  end configure_execution_by_path;

end ut_suite_manager;
/
