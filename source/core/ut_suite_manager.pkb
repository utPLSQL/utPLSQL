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

  function trim_path(a_path varchar2, a_part varchar2) return varchar2 is
  begin
    return substr(a_path, nvl(length(a_part), 0) + 1);
  end;

  function get_schema_info(a_owner_name varchar2) return t_schema_info is
    l_info t_schema_info;
  begin
    select nvl(max(t.last_ddl_time), date '4999-12-31'), count(*)
      into l_info
      from all_objects t
     where t.owner = a_owner_name
       and t.object_type in ('PACKAGE');
    return l_info;
  end;

  function config_package(a_owner_name varchar2, a_object_name varchar2) return ut_logical_suite is
    l_annotation_data    ut_annotations.typ_annotated_package;
    l_suite_name         ut_annotations.t_annotation_name;
    l_test               ut_test;
    l_proc_annotations   ut_annotations.tt_annotations;

    l_default_setup_proc    varchar2(250 char);
    l_default_teardown_proc varchar2(250 char);
    l_suite_setup_proc      varchar2(250 char);
    l_suite_teardown_proc   varchar2(250 char);
    l_suite_path            varchar2(4000 char);

    l_proc_name ut_annotations.t_procedure_name;

    l_owner_name  varchar2(250 char);
    l_object_name varchar2(250 char);
    l_suite       ut_logical_suite;

    l_suite_rollback            integer;
    l_suite_rollback_annotation varchar2(4000);
    e_insufficient_priv         exception;
    pragma exception_init(e_insufficient_priv,-01031);
  begin
    l_owner_name  := a_owner_name;
    l_object_name := a_object_name;
    begin
      ut_metadata.do_resolve(a_owner => l_owner_name, a_object => l_object_name);
    exception
      when e_insufficient_priv then
      return null;
    end;
    l_annotation_data := ut_annotations.get_package_annotations(a_owner_name => l_owner_name, a_name => l_object_name);

    if l_annotation_data.package_annotations.exists('suite') then

      if l_annotation_data.package_annotations.exists('displayname') then
        l_suite_name         := l_annotation_data.package_annotations('displayname').text;
      else
        l_suite_name         := l_annotation_data.package_annotations('suite').text;
      end if;

      if l_annotation_data.package_annotations.exists('suitepath') and l_annotation_data.package_annotations('suitepath').text is not null then
        l_suite_path := l_annotation_data.package_annotations('suitepath').text || '.' || lower(l_object_name);
      end if;

      if l_annotation_data.package_annotations.exists('rollback') then
        l_suite_rollback_annotation := l_annotation_data.package_annotations('rollback').text;
        if lower(l_suite_rollback_annotation) = 'manual' then
          l_suite_rollback := ut_utils.gc_rollback_manual;
        else
          l_suite_rollback := ut_utils.gc_rollback_auto;
        end if;
      else
        l_suite_rollback := ut_utils.gc_rollback_auto;
      end if;

      for i in 1 .. l_annotation_data.procedure_annotations.count loop
        exit when l_default_setup_proc is not null and l_default_teardown_proc is not null and l_suite_setup_proc is not null and l_suite_teardown_proc is not null;
        l_proc_name        := l_annotation_data.procedure_annotations(i).name;
        l_proc_annotations := l_annotation_data.procedure_annotations(i).annotations;

        if l_proc_annotations.exists('beforeeach') and l_default_setup_proc is null then
          l_default_setup_proc := l_proc_name;
        elsif l_proc_annotations.exists('aftereach') and l_default_teardown_proc is null then
          l_default_teardown_proc := l_proc_name;
        elsif l_proc_annotations.exists('beforeall') and l_suite_setup_proc is null then
          l_suite_setup_proc := l_proc_name;
        elsif l_proc_annotations.exists('afterall') and l_suite_teardown_proc is null then
          l_suite_teardown_proc := l_proc_name;
        end if;

      end loop;
      l_suite := ut_suite (
          a_object_owner          => l_owner_name,
          a_object_name           => l_object_name,
          a_name                  => l_object_name, --this could be different for sub-suite (context)
          a_path                  => l_suite_path,  --a patch for this suite (excluding the package name of current suite)
          a_description           => l_suite_name,
          a_rollback_type         => l_suite_rollback,
          a_disabled_flag         => l_annotation_data.package_annotations.exists('disabled'),
          a_before_all_proc_name  => l_suite_setup_proc,
          a_after_all_proc_name   => l_suite_teardown_proc
      );


      for i in 1 .. l_annotation_data.procedure_annotations.count loop
        l_proc_name        := l_annotation_data.procedure_annotations(i).name;
        l_proc_annotations := l_annotation_data.procedure_annotations(i).annotations;
        if l_proc_annotations.exists('test') then
          declare
            l_beforetest_procedure varchar2(30 char);
            l_aftertest_procedure  varchar2(30 char);
            l_rollback_annotation  varchar2(4000);
            l_rollback_type        integer := l_suite_rollback;
            l_displayname          varchar2(4000);
          begin
            if l_proc_annotations.exists('beforetest') then
              l_beforetest_procedure := l_proc_annotations('beforetest').text;
            end if;

            if l_proc_annotations.exists('aftertest') then
              l_aftertest_procedure := l_proc_annotations('aftertest').text;
            end if;

            if l_proc_annotations.exists('displayname') then
              l_displayname := l_proc_annotations('displayname').text;
            else
              l_displayname := l_proc_annotations('test').text;
            end if;

            if l_proc_annotations.exists('rollback') then
              l_rollback_annotation := l_proc_annotations('rollback').text;
              if lower(l_rollback_annotation) = 'manual' then
                l_rollback_type := ut_utils.gc_rollback_manual;
              elsif lower(l_rollback_annotation) = 'auto' then
                l_rollback_type := ut_utils.gc_rollback_auto;
              else
                l_rollback_type := l_suite_rollback;
              end if;
            end if;

            l_test := ut_test(a_object_owner          => l_owner_name
                             ,a_object_name           => l_object_name
                             ,a_name                  => l_proc_name
                             ,a_description           => l_displayname
                             ,a_path                  => l_suite.path || '.' || l_proc_name
                             ,a_rollback_type         => l_rollback_type
                             ,a_disabled_flag         => l_proc_annotations.exists('disabled')
                             ,a_before_test_proc_name => l_beforetest_procedure
                             ,a_after_test_proc_name  => l_aftertest_procedure
                             ,a_before_each_proc_name => l_default_setup_proc
                             ,a_after_each_proc_name  => l_default_teardown_proc);

            l_suite.add_item(l_test);
          end;
        end if;

      end loop;
    end if;
    return l_suite;

  end config_package;

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
    -- form the single-dimension list of suites constructed from parsed packages
    for rec in (select t.owner
                      ,t.object_name
                  from all_objects t
                 where t.owner = a_owner_name
                   and t.status = 'VALID' -- scan only valid specifications
                   and t.object_type in ('PACKAGE')) loop
      -- parse the source of the package
      l_suite := config_package(rec.owner, rec.object_name);

      if l_suite is not null then
        l_all_suites(l_suite.path) := l_suite;
      end if;

    end loop;

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

  function get_schema_ut_packages(a_schema_names ut_varchar2_list) return ut_object_names is
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
      c_root        constant varchar2(32767) := replace(regexp_substr(a_path, '[A-Za-z0-9$#_]+'), '$', '\$');
      c_rest_path   constant varchar2(32767) := regexp_substr(a_path, '\.(.+)', subexpression => 1);
      l_suite       ut_logical_suite;
      l_item        ut_suite_item;
      l_items       ut_suite_items := ut_suite_items();
      l_item_name   varchar2(32767);

    begin
      a_suite.set_disabled_flag(false);

      if a_path is not null and a_suite is not null and a_suite is of (ut_logical_suite) then
        l_suite := treat(a_suite as ut_logical_suite);

        for i in 1 .. l_suite.items.count loop

          l_item := l_suite.items(i);

          l_item_name := l_item.name;
          --l_item_name := regexp_substr(l_item_name,'[A-Za-z0-9$#_]+$'); -- temporary fix. seems like suite have suitepath in object_name
          if regexp_like(l_item_name, c_root, modifier => 'i') then

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

            l_temp_suite := config_package(l_schema, l_package_name);

            if l_temp_suite is null then
              raise_application_error(ut_utils.gc_suite_package_not_found,'Suite package '||l_schema||'.'||l_package_name|| ' not found');
            end if;

            l_path       := rtrim(l_schema || ':' || l_temp_suite.path || '.' || l_procedure_name, '.');
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
