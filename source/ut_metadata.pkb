create or replace package body ut_metadata as

  ------------------------------
  --private definitions

  g_source_view constant varchar2(32) := case when is_dba_source_accessible then 'dba_source' else 'all_source' end;

  function get_source_cursor(a_source_view varchar2 := 'dba_source', a_owner varchar2 := null, a_object varchar2 := null) return sys_refcursor is
    c_query_str constant varchar2(1000) := 'select t.text from ' || a_source_view ||
                                           ' t where t.owner = :a_owner and t.name = :a_object_name and t.type = ''PACKAGE'' order by t.line';
    l_cur sys_refcursor;

  begin
    open l_cur for c_query_str
      using a_owner, a_object;
    return l_cur;
  end;

  function get_source(a_owner varchar2, a_object_name varchar2) return clob is
    type t_source_tab is table of all_source.text%type;
    l_source  clob;
    l_txt_tab t_source_tab;
    l_cur     sys_refcursor;
  begin

    dbms_lob.createtemporary(l_source, true);
    l_cur := get_source_cursor(g_source_view, a_owner, a_object_name);
    fetch l_cur bulk collect into l_txt_tab;
    for i in 1 .. cardinality(l_txt_tab) loop
      dbms_lob.writeappend(l_source, length(l_txt_tab(i)), l_txt_tab(i));
    end loop;
    close l_cur;
    return l_source;

  end get_source;

  $if $$ut_trace $then
  procedure print_parse_results(a_name varchar2, a_annotated_pkg typ_annotated_package) is
    l_name      t_annotation_name := a_annotated_pkg.annotations.first;
    l_proc_name t_annotation_name := a_annotated_pkg.procedures.first;
  begin
    dbms_output.put_line('package: ' || a_name);
    dbms_output.put_line('Annotations count: ' || a_annotated_pkg.annotations.count);

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

  end print_parse_results;
  $end

  ------------------------------
  --public definitions

  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2) is
    l_procedure_name  varchar2(200);
  begin
    do_resolve(a_owner, a_object, l_procedure_name );
  end do_resolve;

  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2) is
    l_name          varchar2(200);
    l_context       integer := 1; --plsql
    l_dblink        varchar2(200);
    l_part1_type    number;
    l_object_number number;
  begin
    l_name := form_name(a_owner, a_object, a_procedure_name);

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
    l_name := trim(a_object);
    if trim(a_owner_name) is not null then
      l_name := trim(a_owner_name) || '.' || l_name;
    end if;
    if trim(a_subprogram) is not null then
      l_name := l_name || '.' || trim(a_subprogram);
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

  function parse_package_annotations(a_owner_name varchar2, a_name varchar2) return typ_annotated_package is
    l_pkg_spec         clob;
    l_package_comments varchar2(32767);
    l_proc_comments    varchar2(32767);
    l_proc_name        t_annotation_name;
    type tt_comment_list is table of varchar2(32767) index by pls_integer;
    l_comments tt_comment_list;

    l_annot_proc_ind   number;
    l_annot_proc_block varchar2(32767);

    c_multiline_comment_pattern   constant varchar2(50) := '/\*.*?\*/';
    c_singleline_comment_pattern  constant varchar2(20) := ' *--(.*?)$';
    c_nonannotat_comment_pattern  constant varchar2(20) := ' *-{2,}\s*[^%]*?$';
    c_comment_replacer_patter     constant varchar2(50) := '{COMMENT#%N%}';
    c_comment_replacer_regex_ptrn constant varchar2(25) := '{COMMENT#(\d+)}';
    c_rgexp_identifier            constant varchar2(50) := '[a-z][a-z0-9#_$]*';
    c_annotation_block_pattern    constant varchar2(200) := '((.*?{COMMENT#\d+}\s?)+)\s*(procedure|function)\s+(' ||
                                                            c_rgexp_identifier || ')';
    l_annotated_pkg typ_annotated_package;

    function get_annotations(a_source varchar2, a_comments tt_comment_list) return tt_annotations is
      l_loop_index            pls_integer := 1;
      l_comment_index         pls_integer;
      l_comment               varchar2(32767);
      l_annotation_str        varchar2(32767);
      l_annotation_params_str varchar2(32767);
      l_annotation_name       varchar2(1000);
      l_annotation_params     tt_annotation_params;
      l_annotations_list      tt_annotations;

      c_annotation_pattern constant varchar2(50) := '%' || c_rgexp_identifier || '(\(.*?\))?';
    begin
      -- loop while there are unprocessed comment blocks
      while 0 != nvl(regexp_instr(srcstr        => a_source
                                 ,pattern       => c_comment_replacer_regex_ptrn
                                 ,occurrence    => l_loop_index
                                 ,subexpression => 1)
                    ,0) loop

        -- define index of the comment block and get it's content from cache
        l_comment_index := to_number(regexp_substr(a_source
                                                  ,c_comment_replacer_regex_ptrn
                                                  ,1
                                                  ,l_loop_index
                                                  ,subexpression => 1));

        l_comment := a_comments(l_comment_index);

        -- strip everything except the annotation itself (spaces and others)
        l_annotation_str := regexp_substr(l_comment, c_annotation_pattern, 1, 1, modifier => 'i');
        if l_annotation_str is not null then

          l_annotation_params.delete;

          -- get the annotation name and it's parameters if present
          l_annotation_name       := lower(regexp_substr(l_annotation_str
                                                        ,'%(' || c_rgexp_identifier || ')'
                                                        ,modifier => 'i'
                                                        ,subexpression => 1));
          l_annotation_params_str := trim(regexp_substr(l_annotation_str, '\((.*?)\)', subexpression => 1));

          if l_annotation_params_str is not null then

            -- parse the annotation parameters and store them as key-value pair array
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

    end get_annotations;

    function delete_multiline_comments(a_pkg_spec in clob) return clob is
    begin
      return regexp_replace(
              srcstr => regexp_replace(
                          srcstr => regexp_replace( srcstr => a_pkg_spec, pattern => c_multiline_comment_pattern, modifier => 'n')
                          ,pattern => c_nonannotat_comment_pattern, modifier => 'm')
              ,pattern    => '((procedure|function)\s+' || c_rgexp_identifier || ')[^;]*'
              ,replacestr => '\1'
              ,modifier   => 'mn'
            );
    --dbms_output.put_line(a_pkg_spec);
    end;
    function extract_and_replace_comments(a_pkg_spec in out nocopy clob) return tt_comment_list is
      l_comments         tt_comment_list;
      l_comment_pos      pls_integer;
      l_comment_replacer varchar2(50);
    begin
      l_comment_pos := 1;
      loop
        l_comment_pos := regexp_instr(srcstr     => a_pkg_spec
                                     ,pattern    => c_singleline_comment_pattern
                                     ,occurrence => 1
                                     ,modifier   => 'm'
                                     ,position   => l_comment_pos
                                      );
        exit when l_comment_pos = 0;
        l_comments(l_comments.count + 1) := trim(regexp_substr(srcstr        => a_pkg_spec
                                                              ,pattern       => c_singleline_comment_pattern
                                                              ,occurrence    => 1
                                                              ,position      => l_comment_pos
                                                              ,modifier      => 'm'
                                                              ,subexpression => 1));

        l_comment_replacer := replace(c_comment_replacer_patter, '%N%', l_comments.count);

        a_pkg_spec    := regexp_replace(srcstr     => a_pkg_spec
                                       ,pattern    => c_singleline_comment_pattern
                                       ,replacestr => l_comment_replacer
                                       ,position   => l_comment_pos
                                       ,occurrence => 1
                                       ,modifier   => 'm');
        l_comment_pos := l_comment_pos + length(l_comment_replacer);

      end loop;
      return l_comments;
    end extract_and_replace_comments;

  begin
    l_pkg_spec := get_source(a_owner_name, a_name);

    if l_pkg_spec is null then
      return null;
    end if;

    l_pkg_spec := delete_multiline_comments(l_pkg_spec);

    -- replace all single line comments with {COMMENT#12} element and store it's content for easier processing
    l_comments := extract_and_replace_comments(l_pkg_spec);

    $if $$ut_trace $then
      dbms_output.put_line(l_pkg_spec);
    $end

    l_package_comments := regexp_substr(srcstr        => l_pkg_spec
                                       ,pattern       => '^\s*(CREATE\s+(OR\s+REPLACE)?(\s+(NON)?EDITIONABLE)?\s+)?PACKAGE .*?\s+(AS|IS)\s+((.*?{COMMENT#\d+}\s?)+)'
                                       ,modifier      => 'i'
                                       ,subexpression => 6);

    -- parsing for package annotations
    if l_package_comments is not null then
      l_annotated_pkg.annotations := get_annotations(l_package_comments, l_comments);
    end if;

    -- loop through procedures and functions of the package and get all the comment blocks just before it's declaration
    l_annot_proc_ind := 1;
    loop
      l_annot_proc_ind := regexp_instr(srcstr     => l_pkg_spec
                                      ,pattern    => c_annotation_block_pattern
                                      ,occurrence => 1
                                      ,modifier   => 'i'
                                      ,position   => l_annot_proc_ind);

      exit when l_annot_proc_ind = 0;

      l_annot_proc_block := regexp_substr(srcstr     => l_pkg_spec
                                         ,pattern    => c_annotation_block_pattern
                                         ,position   => l_annot_proc_ind
                                         ,occurrence => 1
                                         ,modifier   => 'i');

      l_annot_proc_ind := l_annot_proc_ind + length(l_annot_proc_block);

      l_proc_comments := trim(regexp_substr(srcstr        => l_annot_proc_block
                                           ,pattern       => c_annotation_block_pattern
                                           ,modifier      => 'i'
                                           ,subexpression => 1));
      l_proc_name     := trim(regexp_substr(srcstr        => l_annot_proc_block
                                           ,pattern       => c_annotation_block_pattern
                                           ,modifier      => 'i'
                                           ,subexpression => 4));

      -- parse the comment block for the syntactically correct annotations and store them as an array
      l_annotated_pkg.procedures(l_proc_name) := get_annotations(l_proc_comments, l_comments);

    end loop;

    -- printing out parsed structure for debugging
    $if $$ut_trace $then
      print_parse_results(a_name, a_annotated_pkg);
    $end

    return l_annotated_pkg;
  end parse_package_annotations;

  function get_annotation_param(a_param_list tt_annotation_params, a_def_index pls_integer) return varchar2 is
    l_result varchar2(32767);
  begin
    if a_param_list.exists(a_def_index) then
      l_result := a_param_list(a_def_index).value;
    end if;
    return l_result;
  end get_annotation_param;

  function is_dba_source_accessible return boolean is
    l_cursor sys_refcursor;
  begin
    l_cursor := get_source_cursor();
    close l_cursor;
    return true;
  exception
    when others then
      return false;
  end;

end;
/
