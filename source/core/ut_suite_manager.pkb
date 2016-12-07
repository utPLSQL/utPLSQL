create or replace package body ut_suite_manager is

  type tt_schema_suits is table of ut_test_suite index by varchar2(4000 char);
  type tt_schena_suits_list is table of tt_schema_suits index by varchar2(32 char);

  g_schema_suites tt_schena_suits_list;

  function trim_path(a_path varchar2, a_part varchar2) return varchar2 is
  begin
    return substr(a_path, nvl(length(a_part), 0) + 1);
  end;

  function config_package(a_owner_name varchar2, a_object_name varchar2) return ut_test_suite is
    l_annotation_data    ut_annotations.typ_annotated_package;
    l_suite_name         ut_annotations.t_annotation_name;
    l_suite_annot_params ut_annotations.tt_annotation_params;
    l_test               ut_test;
    l_proc_annotations   ut_annotations.tt_annotations;
  
    l_default_setup_proc    varchar2(32 char);
    l_default_teardown_proc varchar2(32 char);
    l_suite_setup_proc      varchar2(32 char);
    l_suite_teardown_proc   varchar2(32 char);
    l_suite_package         varchar2(4000 char);
  
    l_proc_name ut_annotations.t_procedure_name;
  
    l_owner_name  varchar2(32 char);
    l_object_name varchar2(32 char);
    l_suite       ut_test_suite;
  
    l_suite_rollback            integer;
    l_suite_rollback_annotation varchar2(4000);
  
  begin
    l_owner_name  := a_owner_name;
    l_object_name := a_object_name;
  
    ut_metadata.do_resolve(a_owner => l_owner_name, a_object => l_object_name);
    l_annotation_data := ut_annotations.get_package_annotations(a_owner_name => l_owner_name, a_name => l_object_name);
  
    if l_annotation_data.package_annotations.exists('suite') then
      l_suite_annot_params := l_annotation_data.package_annotations('suite');
      l_suite_name         := ut_annotations.get_annotation_param(l_suite_annot_params, 1);
    
      if l_annotation_data.package_annotations.exists('suitepackage') then
        l_suite_package := ut_annotations.get_annotation_param(l_annotation_data.package_annotations('suitepackage'), 1) || '.' ||
                           lower(l_object_name);
      end if;
    
      if l_annotation_data.package_annotations.exists('rollback') then
        l_suite_rollback_annotation := ut_annotations.get_annotation_param(l_annotation_data.package_annotations('rollback')
                                                                          ,1);
        l_suite_rollback            := case lower(l_suite_rollback_annotation)
                                         when 'manual' then
                                          ut_utils.gc_rollback_manual
                                         when 'auto' then
                                          ut_utils.gc_rollback_auto
                                         else
                                          ut_utils.gc_rollback_auto
                                       end;
      else
        l_suite_rollback := ut_utils.gc_rollback_auto;
      end if;
    
      l_suite := ut_test_suite(a_suite_name    => l_suite_name
                              ,a_object_name   => l_object_name
                              ,a_object_path   => l_suite_package
                              ,a_rollback_type => l_suite_rollback);
    
      if l_annotation_data.package_annotations.exists('ignore') then
        l_suite.set_ignore_flag(true);
      end if;
    
      l_proc_name := l_annotation_data.procedure_annotations.first;
      while (l_default_setup_proc is null or l_default_teardown_proc is null or l_suite_setup_proc is null or
            l_suite_teardown_proc is null) and l_proc_name is not null loop
        l_proc_annotations := l_annotation_data.procedure_annotations(l_proc_name);
      
        if l_proc_annotations.exists('setup') and l_default_setup_proc is null then
          l_default_setup_proc := l_proc_name;
        elsif l_proc_annotations.exists('teardown') and l_default_teardown_proc is null then
          l_default_teardown_proc := l_proc_name;
        elsif l_proc_annotations.exists('suitesetup') and l_suite_setup_proc is null then
          l_suite_setup_proc := l_proc_name;
        elsif l_proc_annotations.exists('suiteteardown') and l_suite_teardown_proc is null then
          l_suite_teardown_proc := l_proc_name;
        end if;
      
        l_proc_name := l_annotation_data.procedure_annotations.next(l_proc_name);
      end loop;
    
      if l_suite_setup_proc is not null then
        l_suite.set_suite_setup(a_object_name => l_object_name
                               ,a_proc_name   => l_suite_setup_proc
                               ,a_owner_name  => l_owner_name);
      end if;
    
      if l_suite_teardown_proc is not null then
        l_suite.set_suite_teardown(a_object_name => l_object_name
                                  ,a_proc_name   => l_suite_teardown_proc
                                  ,a_owner_name  => l_owner_name);
      end if;
    
      l_proc_name := l_annotation_data.procedure_annotations.first;
      while l_proc_name is not null loop
      
        l_proc_annotations := l_annotation_data.procedure_annotations(l_proc_name);
        if l_proc_annotations.exists('test') then
          declare
            l_setup_procedure     varchar2(30 char);
            l_teardown_procedure  varchar2(30 char);
            l_rollback_annotation varchar2(4000);
            l_rollback_type       integer := ut_utils.gc_rollback_auto;
          begin
            if l_proc_annotations.exists('testsetup') then
              l_setup_procedure := ut_annotations.get_annotation_param(l_proc_annotations('testsetup'), 1);
            end if;
          
            if l_proc_annotations.exists('testteardown') then
              l_teardown_procedure := ut_annotations.get_annotation_param(l_proc_annotations('testteardown'), 1);
            end if;
          
            if l_proc_annotations.exists('rollback') then
              l_rollback_annotation := ut_annotations.get_annotation_param(l_proc_annotations('rollback'), 1);
              l_rollback_type       := case lower(l_rollback_annotation)
                                         when 'manual' then
                                          ut_utils.gc_rollback_manual
                                         when 'auto' then
                                          ut_utils.gc_rollback_auto
                                       --when 'on-error' then
                                       --  ut_utils.gc_rollback_on_error
                                         else
                                          l_suite_rollback
                                       end;
            end if;
          
            l_test := ut_test(a_object_name        => l_object_name
                             ,a_object_path        => l_suite.object_path || '.' || l_proc_name
                             ,a_test_procedure     => l_proc_name
                             ,a_test_name          => ut_annotations.get_annotation_param(l_proc_annotations('test'), 1)
                             ,a_owner_name         => l_owner_name
                             ,a_setup_procedure    => nvl(l_setup_procedure, l_default_setup_proc)
                             ,a_teardown_procedure => nvl(l_teardown_procedure, l_default_teardown_proc)
                             ,a_rollback_type      => l_rollback_type);
          
            if l_proc_annotations.exists('ignore') then
              l_test.set_ignore_flag(true);
            end if;
          
            l_suite.add_item(l_test);
          end;
        end if;
      
        l_proc_name := l_annotation_data.procedure_annotations.next(l_proc_name);
      end loop;
    end if;
    return l_suite;
  
  end config_package;

  procedure config_schema(a_owner_name varchar2) is
    l_suite ut_test_suite;
  
    l_all_suites tt_schema_suits;
    l_ind        varchar2(4000 char);
    l_path       varchar2(4000 char);
    l_root       varchar2(4000 char);
    l_root_suite ut_test_suite;
  
    l_schema_suites tt_schema_suits;
  
    procedure put(a_root_suite in out nocopy ut_test_suite, a_path varchar2, a_suite ut_test_suite, a_parent_path varchar2 default null) is
      l_temp_root varchar2(4000 char);
      l_path varchar2(4000 char);
      l_cur_item  ut_test_suite;
      l_ind       pls_integer;
    begin
      if a_path like '%.%' then
        l_temp_root := regexp_substr(a_path, '^[^.]+');
        l_path := ltrim(a_parent_path||'.'||l_temp_root,'.');
      
        if a_root_suite is not null then
        
          l_ind := a_root_suite.item_index(l_temp_root);
        
          if l_ind is null then
            l_cur_item := ut_test_suite(a_suite_name  => null
                                       ,a_object_name => l_temp_root
                                       ,a_object_path => l_path);
          else
            l_cur_item := treat(a_root_suite.items(l_ind) as ut_test_suite);
          end if;
        
          put(l_cur_item, trim_path(a_path, l_temp_root || '.'), a_suite, l_path);
        
          if l_ind is null then
            a_root_suite.add_item(l_cur_item);
          else
            a_root_suite.items(l_ind) := l_cur_item;
          end if;
        
        else
          a_root_suite := ut_test_suite(a_suite_name  => null
                                       ,a_object_name => l_temp_root
                                       ,a_object_path => l_path);
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
    procedure print(a_suite ut_test_suite, a_pad pls_integer) is
      l_test ut_test;
    begin
      dbms_output.put_line(lpad(' ', a_pad, ' ') || 'Suite: ' || a_suite.object_name||'('||a_suite.object_path||')');
      dbms_output.put_line(lpad(' ', a_pad, ' ') || 'Items: ');
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_test_suite) then
          print(treat(a_suite.items(i) as ut_test_suite), a_pad + 2);
        else
        
          l_test := treat(a_suite.items(i) as ut_test);
          dbms_output.put_line(lpad(' ', a_pad + 2, ' ') || 'Test: ' || l_test.object_name||'('||l_test.object_path||')');
        end if;
      end loop;
    end print;
    $end
  
  begin
    -- form the single-dimension list of suites constructed from parsed packages
    for rec in (select t.owner
                      ,t.object_name
                  from all_objects t
                 where t.owner = a_owner_name
                   and t.object_type in ('PACKAGE')) loop
      -- parse the source of the package
      l_suite := config_package(rec.owner, rec.object_name);
    
      if l_suite is not null then
        l_all_suites(l_suite.object_path) := l_suite;
      end if;
    
    end loop;
  
    l_schema_suites.delete;
  
    -- Restructure single-dimenstion list into hierarchy of suites by the value of %suitepackage attribute value
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
  
    -- Each nonempty root-suite list for the schema is saved into the cache
    if l_schema_suites.count > 0 then
      g_schema_suites(a_owner_name) := l_schema_suites;
    elsif g_schema_suites.exists(a_owner_name) then
      g_schema_suites.delete(a_owner_name);
    end if;
  
    -- printing results for debugging purpose
    $if $$ut_trace $then
    l_ind := l_schema_suites.first;
    while l_ind is not null loop
      print(l_schema_suites(l_ind), 0);
      l_ind := l_schema_suites.next(l_ind);
    end loop;
    $end
  
  end config_schema;

  procedure run_schema_suites(a_owner_name varchar2, a_reporter in out nocopy ut_reporter, a_force_parse_again boolean default false) is
    l_ind        varchar2(4000 char);
    l_suite      ut_test_suite;
    l_suite_list ut_objects_list := ut_objects_list();
  begin
    --TODO - we do not have a way to pass list of suites here
    a_reporter.before_run(ut_objects_list());
    if not g_schema_suites.exists(a_owner_name) or g_schema_suites(a_owner_name).count = 0 or
       nvl(a_force_parse_again, false) then
      config_schema(a_owner_name);
    end if;
  
    if g_schema_suites.exists(a_owner_name) then
      l_ind := g_schema_suites(a_owner_name).first;
      while l_ind is not null loop
        l_suite := g_schema_suites(a_owner_name) (l_ind);
        l_suite.do_execute(a_reporter => a_reporter);
        l_suite_list.extend; l_suite_list(l_suite_list.last) := l_suite;
        l_ind := g_schema_suites(a_owner_name).next(l_ind);
      end loop;
    else
      -- we have to figure out what to do here
      null;
    end if;
    --TODO - we do not have a way to pass list of suites here
    a_reporter.after_run(l_suite_list);
  end run_schema_suites;

  procedure run_schema_suites_static(a_owner_name varchar2, a_reporter in ut_reporter, a_force_parse_again boolean default false) is
    l_temp_reported ut_reporter;
  begin
    l_temp_reported := a_reporter;
    run_schema_suites(a_owner_name, l_temp_reported, a_force_parse_again);
  end run_schema_suites_static;

  procedure run_cur_schema_suites(a_reporter in out nocopy ut_reporter, a_force_parse_again boolean default false) is
  begin
    run_schema_suites(sys_context('userenv', 'current_schema'), a_reporter, a_force_parse_again);
  end run_cur_schema_suites;

  procedure run_cur_schema_suites_static(a_reporter in ut_reporter, a_force_parse_again boolean default false) is
    l_temp_reported ut_reporter;
  begin
    l_temp_reported := a_reporter;
    run_schema_suites(sys_context('userenv', 'current_schema'), l_temp_reported, a_force_parse_again);
  end run_cur_schema_suites_static;

  function get_schema_suites(a_schema_name in varchar2) return tt_schema_suits is
  begin
    -- Currently cache invalidation on DDL is not implemented so schema is rescaned each time
    --if not g_schema_suites.exists(a_schema_name) then
    --  config_schema(a_schema_name);
    --end if;
    config_schema(a_schema_name);
  
    return g_schema_suites(a_schema_name);
  end get_schema_suites;

  -- Validate all paths are correctly formatted
  procedure validate_paths(a_paths in ut_varchar2_list) is
    l_path varchar2(32767);
  begin
    if a_paths is null or a_paths.count = 0 then
      raise_application_error(ut_utils.gc_path_list_is_empty, 'Path list is empty');
    else
      for i in 1 .. a_paths.count loop
        l_path := a_paths(i);
        if l_path is null or not (regexp_like(l_path, '^\w+(\.\w+){0,2}$') or regexp_like(l_path, '^\w+:\w+(\.\w+)*$')) then
          raise_application_error(ut_utils.gc_invalid_path_format, 'Invalid path format: ' || nvl(l_path, 'NULL'));
        end if;
      end loop;
    end if;
  end validate_paths;
  
  procedure configure_execution_by_path(a_paths in ut_varchar2_list, a_objects_to_run out nocopy ut_objects_list) is
    l_paths           ut_varchar2_list;
    l_path            varchar2(32767);
    l_schema          varchar2(4000);
    l_schema_suites   tt_schema_suits;
    l_index           varchar2(4000 char);
    l_suite           ut_test_suite;
    l_suite_path      varchar2(4000);
    l_root_suite_name varchar2(4000);
    
    function clean_paths(a_paths ut_varchar2_list) return ut_varchar2_list is
      l_paths ut_varchar2_list := ut_varchar2_list();
    begin
      l_paths.extend(a_paths.count);
      for i in 1 .. a_paths.count loop
        l_paths(i) := trim(lower(a_paths(i)));
      end loop;
      l_paths := set(l_paths);
      return l_paths;
    end clean_paths;
    
    procedure skip_by_path(a_suite in out nocopy ut_test_object, a_path varchar2) is
      l_root      constant varchar2(32767) := regexp_substr(a_path, '\w+');
      l_rest_path constant varchar2(32767) := regexp_substr(a_path, '\.(.+)', subexpression => 1);
      l_item  ut_test_object;
      l_items ut_objects_list := ut_objects_list();
      l_object_name varchar2(32767);
      
    begin
      a_suite.set_ignore_flag(false);
    
      if a_path is not null then
      
        for i in 1 .. a_suite.items.count loop
        
          l_item := treat(a_suite.items(i) as ut_test_object);
        
          l_object_name := l_item.object_name;
          --l_object_name := regexp_substr(l_object_name,'\w+$'); -- temporary fix. seems like suite have suitepath in object_name
          if regexp_like(l_object_name, l_root, modifier => 'i') then
            
            skip_by_path(l_item, l_rest_path);          
            l_items.extend;
            l_items(l_items.count) := l_item;

          end if;
          
        end loop;
        
        a_suite.items := l_items;
      
        if l_items.count = 0 then--not l_found then
          raise_application_error(-20203, 'Suite note found');
        end if;
      end if;
    end skip_by_path;

  begin
    l_paths := clean_paths(a_paths);
  
    validate_paths(l_paths);
    a_objects_to_run := ut_objects_list();
    
    -- current implementation operates only on a single path
    -- to be improved later
    for i in 1 .. l_paths.count loop
      l_path   := l_paths(i);
      l_schema := regexp_substr(l_path, '^(\w+)(\.|:|$)', 1, 1, null, 1);
    
      l_schema_suites := get_schema_suites(upper(l_schema));
    
      if regexp_like(l_path, '^\w+$') then
        -- run whole schema
        l_index := l_schema_suites.first;
        while l_index is not null loop
          a_objects_to_run.extend;
          a_objects_to_run(a_objects_to_run.count) := l_schema_suites(l_index);
          l_index := l_schema_suites.next(l_index);
        end loop;
      else
        -- convert SCHEMA.PACKAGE.PROCEDURE syntax to fully qualified path
        if regexp_like(l_path, '^\w+(\.\w+){1,2}$') then
          declare
            l_temp_suite     ut_test_suite;
            l_package_name   varchar2(4000);
            l_procedure_name varchar2(4000);
          begin
            l_package_name   := regexp_substr(l_path, '^\w+\.(\w+)(\.(\w+))?$', subexpression => 1);
            l_procedure_name := regexp_substr(l_path, '^\w+\.(\w+)(\.(\w+))?$', subexpression => 3);
          
            l_temp_suite := config_package(l_schema, l_package_name);
            l_path       := rtrim(l_schema || ':' || l_temp_suite.object_path || '.' || l_procedure_name, '.');
          end;
        end if;

        -- fully quilified path branch in the form
        -- by this time it's the only format left
        -- schema:suite.suite.suite
        l_suite_path      := regexp_substr(l_path, ':(.+)', subexpression => 1);
        l_root_suite_name := regexp_substr(l_suite_path, '^\w+');
        
        l_suite := l_schema_suites(l_root_suite_name);
        
        skip_by_path(l_suite, regexp_substr(l_suite_path, '\.(.+)', subexpression => 1));
        
        a_objects_to_run.extend;
        a_objects_to_run(a_objects_to_run.count) := l_suite;

      end if;
    
    end loop;
  end configure_execution_by_path;

  procedure run(a_paths in ut_varchar2_list, a_reporter in ut_reporter) is
    l_objects_to_run  ut_objects_list;
    l_reporter        ut_reporter := a_reporter;
    ut_running_suite ut_test_suite;
  begin
    configure_execution_by_path(a_paths,l_objects_to_run);
  
    if l_objects_to_run.count > 0 then
      l_reporter.before_run(a_suites => l_objects_to_run);
      for i in 1 .. l_objects_to_run.count loop

        ut_running_suite := treat(l_objects_to_run(i) as ut_test_suite);
        ut_running_suite.do_execute(l_reporter);
        l_objects_to_run(i) := ut_running_suite;

      end loop;
      l_reporter.after_run(a_suites => l_objects_to_run);
    end if;
  end;
  

  procedure run(a_path in varchar2, a_reporter in ut_reporter) is
  begin
    run(ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))), a_reporter);
  end run;

end ut_suite_manager;
/
