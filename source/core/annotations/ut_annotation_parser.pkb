create or replace package body ut_annotation_parser as
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

  ------------------------------
  --private definitions

  type tt_comment_list is table of varchar2(32767) index by pls_integer;

  gc_annotation_qualifier       constant varchar2(1) := '%';
  c_multiline_comment_pattern   constant varchar2(50) := '/\*.*?\*/';
  c_annot_comment_pattern       constant varchar2(30) := '^( |'||chr(09)||')*-- *('||gc_annotation_qualifier||'.*?)$'; -- chr(09) is a tab character
  c_comment_replacer_patter     constant varchar2(50) := '{COMMENT#%N%}';
  c_comment_replacer_regex_ptrn constant varchar2(25) := '{COMMENT#(\d+)}';
  c_regexp_identifier           constant varchar2(50) := '[a-z][a-z0-9#_$]*';
  c_annotation_block_pattern    constant varchar2(200) := '(({COMMENT#.+}'||chr(10)||')+)( |'||chr(09)||')*(procedure|function)\s+(' ||
                                                           c_regexp_identifier || ')';
  c_annotation_pattern          constant varchar2(50) := gc_annotation_qualifier || c_regexp_identifier || '[ '||chr(9)||']*(\(.*?\)\s*?$)?';


  function delete_multiline_comments(a_source in clob) return clob is
  begin
  return  regexp_replace(srcstr   => a_source
                         ,pattern  => c_multiline_comment_pattern
                         ,modifier => 'n');
  end;

  function get_annotations(a_source varchar2, a_comments tt_comment_list, a_subobject_name varchar2 := null) return ut_annotations is
    l_loop_index       pls_integer := 1;
    l_annotation_index pls_integer;
    l_comment          varchar2(32767);
    l_annotation_str   varchar2(32767);
    l_annotation_text  varchar2(32767);
    l_annotation_name  varchar2(1000);
    l_annotations      ut_annotations := ut_annotations();
  begin
    -- loop while there are unprocessed comment blocks
    while 0 != nvl(regexp_instr(srcstr        => a_source
                               ,pattern       => c_comment_replacer_regex_ptrn
                               ,occurrence    => l_loop_index
                               ,subexpression => 1)
                  ,0) loop

      -- define index of the comment block and get it's content from cache
      l_annotation_index := to_number(regexp_substr(a_source
                                                ,c_comment_replacer_regex_ptrn
                                                ,1
                                                ,l_loop_index
                                                ,subexpression => 1));

      l_comment := a_comments( l_annotation_index );

      -- strip everything except the annotation itself (spaces and others)
      l_annotation_str := regexp_substr(l_comment, c_annotation_pattern, 1, 1, modifier => 'i');
      if l_annotation_str is not null then

        -- get the annotation name and it's parameters if present
        l_annotation_name := lower(regexp_substr(l_annotation_str
                                                 ,'%(' || c_regexp_identifier || ')'
                                                 ,modifier => 'i'
                                                 ,subexpression => 1));
        l_annotation_text := trim(regexp_substr(l_annotation_str, '\((.*?)\)\s*$', subexpression => 1));

        l_annotations.extend;
        l_annotations( l_annotations.last) :=
          ut_annotation(l_annotation_index, l_annotation_name, l_annotation_text, a_subobject_name);
      end if;
      l_loop_index := l_loop_index + 1;
    end loop;
    return l_annotations;

  end get_annotations;

  function get_package_annotations(a_source clob, a_comments tt_comment_list) return ut_annotations is
    l_package_comments varchar2(32767);
    l_annotations      ut_annotations := ut_annotations();
  begin
    l_package_comments := regexp_substr(srcstr        => a_source
                                       ,pattern       => '^\s*(CREATE\s+(OR\s+REPLACE)?(\s+(NON)?EDITIONABLE)?\s+)?PACKAGE\s[^;]*?(\s+(AS|IS)\s+)((.*?{COMMENT#\d+}\s?)+)'
                                       ,modifier      => 'i'
                                       ,subexpression => 7);

    -- parsing for package annotations
    if l_package_comments is not null then
      l_annotations := get_annotations(l_package_comments, a_comments);
    end if;

    return l_annotations;
  end;

  function get_procedure_list(a_source clob, a_comments tt_comment_list) return ut_annotations is
    l_proc_comments         varchar2(32767);
    l_proc_name             t_annotation_name;
    l_annot_proc_ind        number;
    l_annot_proc_block      varchar2(32767);
    l_annotations           ut_annotations := ut_annotations();
  begin
    -- loop through procedures and functions of the package and get all the comment blocks just before it's declaration
    l_annot_proc_ind := 1;
    loop
      --find annotated procedure index
      l_annot_proc_ind := regexp_instr(srcstr     => a_source
                                      ,pattern    => c_annotation_block_pattern
                                      ,occurrence => 1
                                      ,modifier   => 'i'
                                      ,position   => l_annot_proc_ind);
      exit when l_annot_proc_ind = 0;

      --get the annotataions with procedure name
      l_annot_proc_block := regexp_substr(srcstr     => a_source
                                         ,pattern    => c_annotation_block_pattern
                                         ,position   => l_annot_proc_ind
                                         ,occurrence => 1
                                         ,modifier   => 'i');

      --extract the annotations
      l_proc_comments := trim(regexp_substr(srcstr        => l_annot_proc_block
                                           ,pattern       => c_annotation_block_pattern
                                           ,modifier      => 'i'
                                           ,subexpression => 1));
      --extract the procedure name
      l_proc_name     := trim(regexp_substr(srcstr        => l_annot_proc_block
                                           ,pattern       => c_annotation_block_pattern
                                           ,modifier      => 'i'
                                           ,subexpression => 5));

      -- parse the comment block for the syntactically correct annotations and store them as an array
      l_annotations := l_annotations multiset union all get_annotations(l_proc_comments, a_comments, l_proc_name);

      --l_annot_proc_ind := l_annot_proc_ind + length(l_annot_proc_block);
      l_annot_proc_ind := regexp_instr(srcstr     => a_source
                                      ,pattern    => ';'
                                      ,occurrence => 1
                                      ,position   => l_annot_proc_ind + length(l_annot_proc_block));
    end loop;

    return l_annotations;
  end;

  function extract_and_replace_comments(a_source in out nocopy clob) return tt_comment_list is
    l_comments         tt_comment_list;
    l_comment_pos      pls_integer;
    l_comment_replacer varchar2(50);
    l_source           clob := a_source;
  begin
    l_comment_pos := 1;
    loop

      l_comment_pos := regexp_instr(srcstr     => a_source
                                   ,pattern    => c_annot_comment_pattern
                                   ,occurrence => 1
                                   ,modifier   => 'm'
                                   ,position   => l_comment_pos);

      exit when l_comment_pos = 0;

      -- position index is shifted by 1 because c_annot_comment_pattern contains ^ as first sign
      -- but after instr index already points to the char on that line
      l_comment_pos := l_comment_pos-1;
      l_comments(l_comments.count + 1) := trim(regexp_substr(srcstr        => a_source
                                                            ,pattern       => c_annot_comment_pattern
                                                            ,occurrence    => 1
                                                            ,position      => l_comment_pos
                                                            ,modifier      => 'm'
                                                            ,subexpression => 2));

      l_comment_replacer := replace(c_comment_replacer_patter, '%N%', l_comments.count);

      l_source    := regexp_replace(srcstr     => a_source
                                   ,pattern    => c_annot_comment_pattern
                                   ,replacestr => l_comment_replacer
                                   ,position   => l_comment_pos
                                   ,occurrence => 1
                                   ,modifier   => 'm');
      dbms_lob.freetemporary(a_source);
      a_source := l_source;
      dbms_lob.freetemporary(l_source);
      l_comment_pos := l_comment_pos + length(l_comment_replacer);

    end loop;

    ut_utils.debug_log(a_source);
    return l_comments;
  end extract_and_replace_comments;

  $if $$ut_trace $then
  procedure print_parse_results(a_annotations ut_annotations) is
  begin
    dbms_output.put_line('Annotations count: ' || a_annotations.count);
    for i in 1 .. a_annotations.count loop
      dbms_output.put_line(xmltype(a_annotations(i)).getclobval());
    end loop;
  end print_parse_results;
  $end

  function parse_package_annotations(a_source clob) return ut_annotations is
    l_source           clob := a_source;
    l_comments         tt_comment_list;
    l_annotations      ut_annotations;
    l_result           ut_annotations;
  begin

    l_source := delete_multiline_comments(l_source);

    -- replace all single line comments with {COMMENT#12} element and store it's content for easier processing
    -- this call modifies l_source
    l_comments := extract_and_replace_comments(l_source);

    l_annotations :=
      get_package_annotations(l_source, l_comments)
      multiset union all get_procedure_list(l_source, l_comments);

    dbms_lob.freetemporary(l_source);
    select value(x)
      bulk collect into l_result
      from table(l_annotations) x
     order by x.position;

--     -- printing out parsed structure for debugging
--     $if $$ut_trace $then
--       print_parse_results(l_result);
--     $end
    return l_result;
  end parse_package_annotations;

  function get_post_processed_source(a_source_lines ut_varchar2_rows) return clob is
    l_lines       sys.dbms_preprocessor.source_lines_t;
    l_source      clob;
  begin
    --convert to preprocessor lines
    for i in 1 .. a_source_lines.count loop
      l_lines(i) := a_source_lines(i);
    end loop;
    --get post-processed source
    l_lines := sys.dbms_preprocessor.get_post_processed_source(l_lines);
    --convert to clob
    for i in 1..l_lines.count loop
      ut_utils.append_to_clob(l_source, replace(l_lines(i), chr(13)||chr(10), chr(10)));
    end loop;
    return l_source;
  end;

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------

  function parse_annotations(a_cursor t_object_sources_cur) return ut_annotated_objects pipelined is
    l_rec         t_object_source;
    l_source      clob;
    l_annotations ut_annotations;
    l_result      ut_annotated_object;
    ex_package_is_wrapped exception;
    pragma exception_init(ex_package_is_wrapped, -24241);

  begin
    if not a_cursor% isopen then
      return;
    end if;
    loop

      fetch a_cursor into l_rec;
      exit when a_cursor%notfound;
      begin
        --convert to post-processed source clob
        l_source := get_post_processed_source(l_rec.lines);
        --parse annotations
        l_annotations := parse_package_annotations(l_source);
        dbms_lob.freetemporary(l_source);
      exception
        when ex_package_is_wrapped then
        null;
      end;
      --convert to query results
      l_result := ut_annotated_object( l_rec.owner, l_rec.name, l_rec.type, l_annotations);

      ut_annotation_cache_manager.update_cache(l_result, l_rec.cache_id);
      if l_annotations is not empty then
        pipe row (l_result);
      end if;
    end loop;
    close a_cursor;
    return;
  end;


  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2) return ut_annotated_objects pipelined is
    l_objects_view   varchar2(200) := ut_metadata.get_dba_view('dba_objects');
    l_sources_view   varchar2(200) := ut_metadata.get_dba_view('dba_source');
    l_obj            ut_annotated_object;
    l_current_schema varchar2(250) := ut_utils.ut_owner;
    l_cursor         sys_refcursor;
    l_cursor_sql     varchar2(32767);
  begin
    l_cursor_sql :=
      q'[with object_cache_info
        as (select /*+ cardinality(i 10000) */ o.owner as object_owner, o.object_name, o.object_type, i.cache_id,
                   case when o.last_ddl_time < i.parse_time then 'N' else 'Y' end as cache_stale
              from ]'||l_objects_view||q'[ o
              left join ]'||l_current_schema||q'[.ut_annotation_cache_info i
                on o.owner = i.object_owner  and o.object_name = i.object_name and o.object_type = i.object_type
             where o.object_type = :a_object_type and o.status = 'VALID' and o.owner = :a_object_owner
           ),
           obj_info_with_source
        as (select /*+ cardinality(o 10000) */o.object_owner, o.object_name, o.object_type, o.cache_stale, o.cache_id, s.line, s.text
              from object_cache_info o
              left join ]'||l_sources_view||q'[ s
                on s.name  = o.object_name
               and s.type  = :a_object_type
               and s.owner = :a_object_owner
               and o.cache_stale = 'Y'
           ),
           obj_info_source_grouped
        as (select o.object_owner, o.object_name, o.object_type, o.cache_stale, o.cache_id,
                   cast(collect(o.text order by o.line) as ]'||l_current_schema||q'[.ut_varchar2_rows) as texts
              from obj_info_with_source o
             group by o.object_owner, o.object_type, o.object_name, o.cache_stale, cache_id
             order by o.object_owner, o.object_type, o.object_name
          )
      select obj
        from (
          select ]'||l_current_schema||q'[.ut_annotated_object(o.object_owner, o.object_name, o.object_type,
                 cast(collect(
                       ]'||l_current_schema||q'[.ut_annotation(c.annotation_position, c.annotation_name, c.annotation_text, c.subobject_name) order by c.annotation_position )
                      as ]'||l_current_schema||q'[.ut_annotations)
                 ) as obj
            from obj_info_source_grouped o
            join ]'||l_current_schema||q'[.ut_annotation_cache c
              on o.cache_id = c.cache_id
           where o.cache_stale = 'N'
           group by o.object_owner, o.object_name, o.object_type
          union all
          -- this query needs to be executed as last part of the union
          -- as it is updating the cache_stale flag in an autonomous transaction
          select value(c) as obj
            from table(
              ]'||l_current_schema||q'[.ut_annotation_parser.parse_annotations(
                cursor(select o.object_owner, o.object_name, o.object_type, o.cache_id, o.texts from obj_info_source_grouped o where o.cache_stale = 'Y')
              )
            ) c
        ) a
      order by a.obj.object_owner, a.obj.object_type, a.obj.object_name]';
    open l_cursor for l_cursor_sql using a_object_type, a_object_owner, a_object_type, a_object_owner;
    loop
      fetch l_cursor into l_obj;
      exit when l_cursor%notfound;
      pipe row (l_obj);
    end loop;
    close l_cursor;
    return;
  end;

  function get_package_annotations(a_owner_name varchar2, a_name varchar2) return ut_annotations is
    l_source clob;
    ex_package_is_wrapped exception;
    pragma exception_init(ex_package_is_wrapped, -24241);
  begin
    return parse_package_annotations(ut_metadata.get_package_spec_source(a_owner_name, a_name));
  exception
    when ex_package_is_wrapped then
      return ut_annotations();
  end;


  -- parse the annotation parameters and return as key-value pair array
  function parse_annotation_params(a_annotation_text varchar2) return tt_annotation_params is
    l_annotation_params   tt_annotation_params;
    l_param_str           varchar2(32767);
    l_param_item          typ_annotation_param;
    l_param_item_empty    typ_annotation_param;
    c_annot_param_pattern constant varchar2(50) := '(.+?)(,|$)';
  begin
    if a_annotation_text is not null then
      for param_ind in 1 .. regexp_count(a_annotation_text, c_annot_param_pattern) loop
        l_param_str := regexp_substr(srcstr        => a_annotation_text
                                    ,pattern       => c_annot_param_pattern
                                    ,occurrence    => param_ind
                                    ,subexpression => 1);
        l_param_item := l_param_item_empty;
        l_param_item.key   := regexp_substr(srcstr        => l_param_str
                                           ,pattern       => '(' || c_regexp_identifier || ')\s*='
                                           ,modifier      => 'i'
                                           ,subexpression => 1);
        l_param_item.val := trim(regexp_substr(l_param_str, '(.+?=)?(.*$)', subexpression => 2));

        l_annotation_params(l_annotation_params.count + 1) := l_param_item;
      end loop;
    end if;
    return l_annotation_params;
  end;

end ut_annotation_parser;
/
