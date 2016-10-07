create or replace package body ut_suite_manager is

  type tt_schema_suits is table of ut_test_suite index by varchar2(4000 char);
  type tt_schena_suits_list is table of tt_schema_suits index by varchar2(32 char);

  g_schema_suites tt_schena_suits_list;

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
  
    l_proc_name  ut_annotations.t_procedure_name;
  
    l_owner_name  varchar2(32 char);
    l_object_name varchar2(32 char);
    l_suite       ut_test_suite;
    
    l_suite_rollback integer;
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
      else
        l_suite_package := lower(l_object_name);
      end if;
      
      if l_annotation_data.package_annotations.exists('rollback') then
        l_suite_rollback_annotation := ut_annotations.get_annotation_param(l_annotation_data.package_annotations('rollback'), 1);
        l_suite_rollback := case lower(l_suite_rollback_annotation) 
                              when 'manual' then
                                ut_utils.gc_rollback_manual
                              when 'auto' then
                                ut_utils.gc_rollback_auto
                              --when 'on-error' then
                              --  ut_utils.gc_rollback_on_error
                              else
                                ut_utils.gc_rollback_auto
                            end;
      else
        l_suite_rollback := ut_utils.gc_rollback_auto;
      end if;
    
      l_suite := ut_test_suite(l_suite_name, l_suite_package, a_rollback_type => l_suite_rollback);
    
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
              l_rollback_type := case lower(l_rollback_annotation) 
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
                             ,a_test_procedure     => l_proc_name
                             ,a_test_name          => ut_annotations.get_annotation_param(l_proc_annotations('test'), 1)
                             ,a_owner_name         => l_owner_name
                             ,a_setup_procedure    => nvl(l_setup_procedure, l_default_setup_proc)
                             ,a_teardown_procedure => nvl(l_teardown_procedure, l_default_teardown_proc)
                             ,a_rollback_type      => l_rollback_type);
          
            l_suite.add_item(l_test);
          end;
        end if;

        l_proc_name := l_annotation_data.procedure_annotations.next(l_proc_name);
      end loop;
    end if;
    return l_suite;

  end config_package;

  procedure config_schema(a_owner_name varchar2) is
    l_suite      ut_test_suite;
    l_suite_path varchar2(4000);
  
    l_all_suites tt_schema_suits;
    l_ind        varchar2(4000 char);
    l_path       varchar2(4000 char);
    l_root       varchar2(4000 char);
    l_root_suite ut_test_suite;
  
    l_schema_suites tt_schema_suits;
  
    procedure put(a_root_suite in out nocopy ut_test_suite, a_path varchar2, a_suite ut_test_suite) is
      l_temp_root varchar2(4000 char);
      l_cur_item  ut_test_suite;
      l_ind       pls_integer;
    begin
      if a_path like '%.%' then
        l_temp_root := regexp_substr(a_path, '^[^.]+');
      
        if a_root_suite is not null then
        
          l_ind := a_root_suite.item_index(l_temp_root);
        
          if l_ind is null then
            l_cur_item := ut_test_suite(null, l_temp_root);
          else
            l_cur_item := treat(a_root_suite.items(l_ind) as ut_test_suite);
          end if;
        
          put(l_cur_item, ltrim(a_path, l_temp_root || '.'), a_suite);
        
          if l_ind is null then
            a_root_suite.add_item(l_cur_item);
          else
            a_root_suite.items(l_ind) := l_cur_item;
          end if;
        
        else
          a_root_suite := ut_test_suite(null, l_temp_root);
          put(a_root_suite, ltrim(a_path, l_temp_root || '.'), a_suite);
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
      dbms_output.put_line(lpad(' ', a_pad, ' ') || 'Suite: ' || a_suite.object_name);
      dbms_output.put_line(lpad(' ', a_pad, ' ') || 'Items: ');
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_test_suite) then
          print(treat(a_suite.items(i) as ut_test_suite), a_pad + 2);
        else
        
          l_test := treat(a_suite.items(i) as ut_test);
          dbms_output.put_line(lpad(' ', a_pad + 2, ' ') || 'Test: ' || l_test.object_name);
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
        l_all_suites(l_suite.object_name) := l_suite;
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
        l_path       := ltrim(l_ind, l_root || '.');
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
    l_ind   varchar2(4000 char);
    l_suite ut_test_suite;
  begin
    if not g_schema_suites.exists(a_owner_name) or g_schema_suites(a_owner_name).count = 0 or
       nvl(a_force_parse_again, false) then
      config_schema(a_owner_name);
    end if;
  
    if g_schema_suites.exists(a_owner_name) then
      l_ind := g_schema_suites(a_owner_name).first;
      while l_ind is not null loop
        l_suite := g_schema_suites(a_owner_name) (l_ind);
        l_suite.execute(a_reporter => a_reporter);
        g_schema_suites(a_owner_name)(l_ind) := l_suite;
        l_ind := g_schema_suites(a_owner_name).next(l_ind);
      end loop;
    else
      -- we have to figure out what to do here
      null;
    end if;
  
  end run_schema_suites;

  procedure run_schema_suites_static(a_owner_name varchar2, a_reporter in ut_reporter, a_force_parse_again boolean default false) is
    l_temp_reported ut_reporter;
  begin
    l_temp_reported := a_reporter;
    run_schema_suites(a_owner_name, l_temp_reported);
  end run_schema_suites_static;

  procedure run_cur_schema_suites(a_reporter in out nocopy ut_reporter, a_force_parse_again boolean default false) is
  begin
    run_schema_suites(sys_context('userenv', 'current_schema'), a_reporter);
  end run_cur_schema_suites;

  procedure run_cur_schema_suites_static(a_reporter in ut_reporter, a_force_parse_again boolean default false) is
    l_temp_reported ut_reporter;
  begin
    l_temp_reported := a_reporter;
    run_schema_suites(sys_context('userenv', 'current_schema'), l_temp_reported);
  end run_cur_schema_suites_static;

end ut_suite_manager;
/
