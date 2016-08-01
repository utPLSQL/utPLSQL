create or replace package body ut_metadata as

  gc_print_debug constant boolean := false;

  procedure do_resolve(a_owner in out varchar2, a_object in out varchar2, a_procedure_name in out varchar2) is
    l_name          varchar2(200);
    l_context       integer;
    l_dblink        varchar2(200);
    l_part1_type    number;
    l_object_number number;
  begin
    l_name := form_name(a_owner, a_object, a_procedure_name);
  
    l_context := 1; --plsql
  
    dbms_utility.name_resolve(name          => l_name
                             ,context       => l_context
                             ,schema        => a_owner
                             ,part1         => a_object
                             ,part2         => a_procedure_name
                             ,dblink        => l_dblink
                             ,part1_type    => l_part1_type
                             ,object_number => l_object_number);
  
  end do_resolve;

  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2 is
    l_name varchar2(200);
  begin
    l_name := a_object;
    if trim(a_owner_name) is not null then
      l_name := trim(a_owner_name) || '.' || l_name;
    end if;
    if trim(a_subprogram) is not null then
      l_name := l_name || '.' || a_subprogram;
    end if;
    return l_name;
  end form_name;

  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean as
    l_cnt            number;
    l_schema         varchar2(200);
    l_package_name   varchar2(200);
    l_procedure_name varchar2(200);
  begin
  
    l_schema       := a_owner_name;
    l_package_name := a_package_name;
  
    do_resolve(l_schema, l_package_name, l_procedure_name);
  
    select count(decode(status, 'VALID', 1, null)) / count(*)
      into l_cnt
      from all_objects
     where owner = l_schema
       and object_name = l_package_name
       and object_type in ('PACKAGE', 'PACKAGE BODY');
  
    -- expect both package and body to be valid
    return l_cnt = 1;
  exception
    when others then
      return false;
  end;

  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean as
    l_cnt            number;
    l_schema         varchar2(200);
    l_package_name   varchar2(200);
    l_procedure_name varchar2(200);
  begin
  
    l_schema         := a_owner_name;
    l_package_name   := a_package_name;
    l_procedure_name := a_procedure_name;
  
    do_resolve(l_schema, l_package_name, l_procedure_name);
  
    select count(*)
      into l_cnt
      from all_procedures
     where owner = l_schema
       and object_name = l_package_name
       and procedure_name = l_procedure_name;
  
    --expect one method only for the package with that name.
    return l_cnt = 1;
  exception
    when others then
      return false;
  end;

  function resolvable(a_owner in varchar2, a_object in varchar2, a_procedurename in varchar2) return boolean is
    l_owner          varchar2(200);
    l_object_name    varchar2(200);
    l_procedure_name varchar2(200);
  begin
    l_owner          := a_owner;
    l_object_name    := a_object;
    l_procedure_name := a_procedurename;
    do_resolve(l_owner, l_object_name, l_procedure_name);
    return true;
  exception
    when others then
      return false;
  end resolvable;

  procedure parse_package_annotations(a_owner_name varchar2, a_name varchar2, a_annotated_pkg out typ_annotated_package) is
    l_pkg_spec         clob;
    l_package_comments varchar2(32767);
    l_proc_comments    varchar2(32767);
    l_proc_name        t_annotation_name;
    type tt_comment_list is table of varchar2(32767) index by pls_integer;
    l_comments tt_comment_list;
  
    l_comment varchar2(32767);
  
    c_multiline_comment_pattern   constant varchar2(50) := '/\*.*?\*/';
    c_singleline_comment_pattern  constant varchar2(20) := ' *-{2,}(.*?)$';
    c_comment_replacer_patter     constant varchar2(50) := '{COMMENT#%N%}';
    c_comment_replacer_regex_ptrn constant varchar2(25) := '{COMMENT#(\d+)}';
    c_rgexp_identifier            constant varchar2(50) := '[a-z][a-z0-9#_$]*';
    l_comment_replacer varchar2(50);
  
    --v_annotated_pkg typ_annotated_package;
  
    function get_annotations(a_source varchar2) return tt_annotations is
      l_loop_index            pls_integer;
      l_comment_index         pls_integer;
      l_comment               varchar2(32767);
      l_annotation_str        varchar2(32767);
      l_annotation_params_str varchar2(32767);
      l_annotation_name       varchar2(1000);
      --v_annotation            typ_annotation;
      l_annotation_params tt_annotation_params;
      l_annotations_list  tt_annotations;
    
      c_annotation_pattern constant varchar2(50) := '%' || c_rgexp_identifier || '(\(.*?\))?';
    begin
      l_loop_index := 1;
      while 0 != nvl(regexp_instr(srcstr        => a_source
                                 ,pattern       => c_comment_replacer_regex_ptrn
                                 ,occurrence    => l_loop_index
                                 ,subexpression => 1)
                    ,0) loop
        l_comment_index := to_number(regexp_substr(a_source
                                                  ,c_comment_replacer_regex_ptrn
                                                  ,1
                                                  ,l_loop_index
                                                  ,subexpression => 1));
      
        l_comment := l_comments(l_comment_index);
      
        l_annotation_str := regexp_substr(l_comment, c_annotation_pattern, 1, 1, modifier => 'i');
        if l_annotation_str is not null then
        
          l_annotation_params.delete;
        
          l_annotation_name       := lower(regexp_substr(l_annotation_str
                                                        ,'%(' || c_rgexp_identifier || ')'
                                                        ,modifier => 'i'
                                                        ,subexpression => 1));
          l_annotation_params_str := trim(regexp_substr(l_annotation_str, '\((.*?)\)', subexpression => 1));
        
          if l_annotation_params_str is not null then
            for param_ind in 1 .. regexp_count(l_annotation_params_str, '(.+?)(,|$)') loop
              declare
                l_param_str  varchar2(32767);
                l_param_item typ_annotation_param;
              begin
                l_param_str := regexp_substr(srcstr        => l_annotation_params_str
                                            ,pattern       => '(.+?)(,|$)'
                                            ,occurrence    => param_ind
                                            ,subexpression => 1);
              
                l_param_item.key   := regexp_substr(srcstr        => l_param_str
                                                   ,pattern       => '(' || c_rgexp_identifier || ')\s*='
                                                   ,modifier      => 'i'
                                                   ,subexpression => 1);
                l_param_item.value := regexp_substr(l_param_str, '(.+?=)?(.*$)', subexpression => 2);
              
                l_annotation_params(l_annotation_params.count + 1) := l_param_item;
              end;
            end loop;
          end if;
        
          l_annotations_list(l_annotation_name) := l_annotation_params;
        end if;
        l_loop_index := l_loop_index + 1;
      end loop;
    
      return l_annotations_list;
    
    end;
  begin
    l_pkg_spec := dbms_metadata.get_ddl(object_type => 'PACKAGE_SPEC', name => a_name, schema => a_owner_name);
  
    /*LOOP
    
      v_comment := TRIM(regexp_substr(srcstr     => v_pkg_spec
                                     ,pattern    => c_multiline_comment_pattern
                                     ,occurrence => 1
                                     ,modifier   => 'n'));
    
      EXIT WHEN v_comment IS NULL;
      v_comments(v_comments.count + 1) := v_comment;
    
      v_comment_replacer := REPLACE(c_comment_replacer_patter, '%N%', v_comments.count);
      v_pkg_spec         := regexp_replace(srcstr     => v_pkg_spec
                                          ,pattern    => c_multiline_comment_pattern
                                          ,replacestr => v_comment_replacer
                                          ,occurrence => 1
                                          ,modifier   => 'n');
    
    END LOOP;*/
  
    -- delete multiline comments
    l_pkg_spec := regexp_replace(srcstr => l_pkg_spec, pattern => c_multiline_comment_pattern, modifier => 'n');
  
    loop
      l_comment := trim(regexp_substr(srcstr        => l_pkg_spec
                                     ,pattern       => c_singleline_comment_pattern
                                     ,occurrence    => 1
                                     ,modifier      => 'm'
                                     ,subexpression => 1));
    
      exit when l_comment is null;
      l_comments(l_comments.count + 1) := l_comment;
      l_comment_replacer := replace(c_comment_replacer_patter, '%N%', l_comments.count);
    
      l_pkg_spec := regexp_replace(srcstr     => l_pkg_spec
                                  ,pattern    => c_singleline_comment_pattern
                                  ,replacestr => l_comment_replacer
                                  ,occurrence => 1
                                  ,modifier   => 'm');
    
    end loop;
  
    if gc_print_debug then
      dbms_output.put_line(l_pkg_spec);
    end if;
  
    l_package_comments := regexp_substr(srcstr        => l_pkg_spec
                                       ,pattern       => 'CREATE\s+(OR\s+REPLACE) PACKAGE .*?(AS|IS)\s+((.*?{COMMENT#\d+}\s?)+)'
                                       ,modifier      => 'i'
                                       ,subexpression => 3);
  
    -- parsing for package annotations
    --v_annotated_pkg.name := pkg_name;
    if l_package_comments is not null then
      a_annotated_pkg.annotations := get_annotations(l_package_comments);
    end if;
  
    for annot_proc_ind in 1 .. regexp_count(srcstr   => l_pkg_spec
                                           ,pattern  => '((.*?{COMMENT#\d+}\s?)+)\s*(procedure|function)\s+(' ||
                                                        c_rgexp_identifier || ')'
                                           ,modifier => 'i') loop
    
      l_proc_comments := trim(regexp_substr(srcstr        => l_pkg_spec
                                           ,pattern       => '((.*?{COMMENT#\d+}\s?)+)\s*(procedure|function)\s+(' ||
                                                             c_rgexp_identifier || ')'
                                           ,occurrence    => annot_proc_ind
                                           ,modifier      => 'i'
                                           ,subexpression => 1));
      l_proc_name     := trim(regexp_substr(srcstr        => l_pkg_spec
                                           ,pattern       => '((.*?{COMMENT#\d+}\s?)+)\s*(procedure|function)\s+(' ||
                                                             c_rgexp_identifier || ')'
                                           ,occurrence    => annot_proc_ind
                                           ,modifier      => 'i'
                                           ,subexpression => 4));
    
      a_annotated_pkg.procedures(l_proc_name) := get_annotations(l_proc_comments);
    
    end loop;
  
    if gc_print_debug then
    
      dbms_output.put_line('package: ' || a_name);
      dbms_output.put_line('Annotations count: ' || a_annotated_pkg.annotations.count);
    
      declare
        l_name      t_annotation_name := a_annotated_pkg.annotations.first;
        l_proc_name t_annotation_name := a_annotated_pkg.procedures.first;
      begin
        while l_name is not null loop
          dbms_output.put_line('  @' || l_name);
          if a_annotated_pkg.annotations(l_name).count > 0 then
            dbms_output.put_line('    Parameters:');
          
            for j in 1 .. a_annotated_pkg.annotations(l_name).count loop
              dbms_output.put_line('    ' || nvl(a_annotated_pkg.annotations(l_name)(j).key, '<Anonimous>') || ' = ' ||
                                   nvl(a_annotated_pkg.annotations(l_name)(j).value, 'NULL'));
            end loop;
          else
            dbms_output.put_line('    No parameters.');
          end if;
        
          l_name := a_annotated_pkg.annotations.next(l_name);
        
        end loop;
      
        dbms_output.put_line('Procedures count: ' || a_annotated_pkg.procedures.count);
      
        while l_proc_name is not null loop
          dbms_output.put_line(rpad('-', 80, '-'));
          dbms_output.put_line('  Procedure: ' || l_proc_name);
          dbms_output.put_line('  Annotations count: ' || a_annotated_pkg.procedures(l_proc_name).count);
        
          l_name := a_annotated_pkg.procedures(l_proc_name).first;
          while l_name is not null loop
            dbms_output.put_line('    @' || l_name);
            if a_annotated_pkg.procedures(l_proc_name)(l_name).count > 0 then
              dbms_output.put_line('      Parameters:');
            
              for j in 1 .. a_annotated_pkg.procedures(l_proc_name)(l_name).count loop
                dbms_output.put_line('      ' ||
                                     nvl(a_annotated_pkg.procedures(l_proc_name) (l_name)(j).key, '<Anonymous>') ||
                                     ' = ' || nvl(a_annotated_pkg.procedures(l_proc_name) (l_name)(j).value, 'NULL'));
              end loop;
            else
              dbms_output.put_line('      No parameters.');
            end if;
          
            l_name := a_annotated_pkg.procedures(l_proc_name).next(l_name);
          end loop;
        
          l_proc_name := a_annotated_pkg.procedures.next(l_proc_name);
        end loop;
      
      end;
    
    end if;
  
  end parse_package_annotations;

  function get_annotation_param(a_param_list tt_annotation_params, a_def_index pls_integer) return varchar2 is
    l_result varchar2(32767);
  begin
    if a_param_list.exists(a_def_index) then
      l_result := a_param_list(a_def_index).value;
    end if;
    return l_result;
  end get_annotation_param;
end;
/
