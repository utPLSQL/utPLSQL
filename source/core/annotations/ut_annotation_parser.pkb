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

  procedure add_annotations(
    a_annotations in out nocopy ut_annotations,
    a_source varchar2,
    a_comments tt_comment_list,
    a_subobject_name varchar2 := null
  ) is
    l_loop_index       pls_integer := 1;
    l_annotation_index pls_integer;
    l_comment          varchar2(32767);
    l_annotation_str   varchar2(32767);
    l_annotation_text  varchar2(32767);
    l_annotation_name  varchar2(1000);
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

        a_annotations.extend;
        a_annotations( a_annotations.last) :=
          ut_annotation(l_annotation_index, l_annotation_name, l_annotation_text, a_subobject_name);
      end if;
      l_loop_index := l_loop_index + 1;
    end loop;

  end add_annotations;

  procedure add_package_annotations(a_annotations in out nocopy ut_annotations, a_source clob, a_comments tt_comment_list) is
    l_package_comments varchar2(32767);
  begin
    l_package_comments := regexp_substr(srcstr        => a_source
                                       ,pattern       => '^\s*(CREATE\s+(OR\s+REPLACE)?(\s+(NON)?EDITIONABLE)?\s+)?PACKAGE\s[^;]*?(\s+(AS|IS)\s+)((.*?{COMMENT#\d+}\s?)+)'
                                       ,modifier      => 'i'
                                       ,subexpression => 7);

    -- parsing for package annotations
    if l_package_comments is not null then
      add_annotations(a_annotations, l_package_comments, a_comments);
    end if;
  end add_package_annotations;

  procedure add_procedure_annotations(a_annotations in out nocopy ut_annotations, a_source clob, a_comments tt_comment_list) is
    l_proc_comments         varchar2(32767);
    l_proc_name             varchar2(250);
    l_annot_proc_ind        number;
    l_annot_proc_block      varchar2(32767);
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
      add_annotations(a_annotations, l_proc_comments, a_comments, l_proc_name);

      --l_annot_proc_ind := l_annot_proc_ind + length(l_annot_proc_block);
      l_annot_proc_ind := regexp_instr(srcstr     => a_source
                                      ,pattern    => ';'
                                      ,occurrence => 1
                                      ,position   => l_annot_proc_ind + length(l_annot_proc_block) );
    end loop;
  end add_procedure_annotations;

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

  function parse_object_annotations(a_source_lines in out nocopy dbms_preprocessor.source_lines_t) return ut_annotations is
    l_processed_lines dbms_preprocessor.source_lines_t;
    l_source          clob;
    l_annotations     ut_annotations := ut_annotations();
    ex_package_is_wrapped exception;
    pragma exception_init(ex_package_is_wrapped, -24241);

  begin
    if a_source_lines.count > 0 then
      --convert to post-processed source clob
      begin
        --get post-processed source
        l_processed_lines := sys.dbms_preprocessor.get_post_processed_source(a_source_lines);
        --convert to clob
        for i in 1..l_processed_lines.count loop
          ut_utils.append_to_clob(l_source, replace(l_processed_lines(i), chr(13)||chr(10), chr(10)));
        end loop;
        --parse annotations
        l_annotations := parse_object_annotations(l_source);
        dbms_lob.freetemporary(l_source);
      exception
        when ex_package_is_wrapped then
          null;
      end;
    end if;
    a_source_lines.delete;
    return l_annotations;
  end;

  function get_annotated_objects_cursor(a_object_owner varchar2, a_object_type varchar2, a_object_name varchar2) return sys_refcursor is
    l_result       sys_refcursor;
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
    l_objects_view varchar2(200) := ut_metadata.get_dba_view('dba_objects');
    l_cursor_text  long;
  begin
    l_cursor_text :=
      q'[select ]'||l_ut_owner||q'[.ut_annotation_cached_object(
                    object_owner => o.owner,
                    object_name => o.object_name,
                    object_type => o.object_type,
                    needs_refresh => case when o.last_ddl_time < i.parse_time then 'N' else 'Y' end,
                    cache_id => i.cache_id
                  )
           from ]'||l_objects_view||q'[ o
           left join ut3.ut_annotation_cache_info i
             on o.owner = i.object_owner and o.object_name = i.object_name and o.object_type = i.object_type
          where o.owner = :a_object_owner
            and o.object_type = :a_object_type
            and o.status = 'VALID'
            and :a_object_name ]'|| case when a_object_name is not null then '= o.object_name' else 'is null' end;
    open l_result for l_cursor_text  using a_object_owner, a_object_type, a_object_name;
    return l_result;
  end;

  function get_sources_for_annotations(a_object_owner varchar2, a_object_type varchar2, a_object_name varchar2) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_dba_view('dba_source');
  begin
    open l_result for
     q'[select s.name, s.text
          from ]'||l_sources_view||q'[ s
         where s.type = :a_object_type
           and s.owner = :a_object_owner
           and s.name
            in (select x.name
                  from ]'||l_sources_view||q'[ x
                 where x.type = :a_object_type
                   and x.owner = :a_object_owner
                   and x.text like '%--%\%%' escape '\'
                   and :a_object_name ]'|| case when a_object_name is not null then '= x.name' else 'is null' end || q'[
               )
          order by name, line]'
      using a_object_type, a_object_owner, a_object_type, a_object_owner, a_object_name;

    return l_result;
  end;

  function get_sources_for_annotations(a_object_owner varchar2, a_object_type varchar2, a_objects_to_refresh ut_annotation_cached_objects) return sys_refcursor is
    l_result       sys_refcursor;
    l_sources_view varchar2(200) := ut_metadata.get_dba_view('dba_source');
    l_card         natural;
  begin
    l_card := ut_utils.scale_cardinality(cardinality(a_objects_to_refresh));
    open l_result for
     q'[select /*+ cardinality( r ]'||l_card||q'[ )*/
               s.name, s.text
          from table(:a_objects_to_refresh) r
          join ]'||l_sources_view||q'[ s
            on s.name = r.object_name
         where s.type = :a_object_type
           and s.owner = :a_object_owner
           and s.name
            in (select /*+ cardinality( x ]'||l_card||q'[ )*/
                       x.name
                  from table(:a_objects_to_refresh) t
                  join ]'||l_sources_view||q'[ x
                    on x.name = t.object_name
                 where x.type = :a_object_type
                   and x.owner = :a_object_owner
                   and x.text like '%--%\%%' escape '\'
               )
          order by name, line]'
      using a_objects_to_refresh, a_object_type, a_object_owner, a_objects_to_refresh, a_object_type, a_object_owner;

    return l_result;
  end;

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------

  function parse_object_annotations(a_source clob) return ut_annotations is
    l_source           clob := a_source;
    l_comments         tt_comment_list;
    l_annotations      ut_annotations := ut_annotations();
    l_result           ut_annotations;
  begin

    l_source := delete_multiline_comments(l_source);

    -- replace all single line comments with {COMMENT#12} element and store it's content for easier processing
    -- this call modifies l_source
    l_comments := extract_and_replace_comments(l_source);

    add_package_annotations(l_annotations, l_source, l_comments);
    add_procedure_annotations(l_annotations, l_source, l_comments);


    dbms_lob.freetemporary(l_source);
    select value(x)
      bulk collect into l_result
      from table(l_annotations) x
     order by x.position;

    -- printing out parsed structure for debugging
    $if $$ut_trace $then
      print_parse_results(l_result);
      dbms_output.put_line('Annotations count: ' || l_result.count);
      for i in 1 .. l_result.count loop
        dbms_output.put_line(xmltype(l_result(i)).getclobval());
      end loop;
    $end
    return l_result;
  end parse_object_annotations;

  function get_annotated_objects(a_object_owner varchar2, a_object_type varchar2, a_object_name varchar2 := null) return ut_annotated_objects pipelined is
    l_info_rows           ut_annotation_cached_objects;
    l_in_cache            ut_annotation_cached_objects;
    l_to_parse            ut_annotation_cached_objects := ut_annotation_cached_objects();
    l_cursor              sys_refcursor;
    l_results             ut_annotated_objects;
    l_result              ut_annotated_object;
    c_object_fetch_limit  constant integer := 10;
    c_lines_fetch_limit   constant integer := 1000;
    l_lines               dbms_preprocessor.source_lines_t;
    l_names               dbms_preprocessor.source_lines_t;
    l_name                varchar2(250) := '''';
    l_object_lines        dbms_preprocessor.source_lines_t;
  begin
    --get information about cached objects
    l_cursor := get_annotated_objects_cursor(a_object_owner, a_object_type, a_object_name);
    fetch l_cursor bulk collect into l_info_rows;
    close l_cursor;

    --get list of objects in cache
    select value(x) bulk collect into l_in_cache from table(l_info_rows) x where x.needs_refresh = 'N';

    --if not all in cache, get list of objects to refresh
    if l_in_cache.count <= l_info_rows.count then
      select value(x) bulk collect into l_to_parse from table(l_info_rows) x where x.needs_refresh = 'Y';
    end if;

    --pipe annotations from cache
    if l_in_cache.count > 0 then
      l_cursor := ut_annotation_cache_manager.get_annotations_for_objects(l_in_cache);
      loop
        fetch l_cursor bulk collect into l_results limit c_object_fetch_limit;
        for i in 1 .. l_results.count loop
          pipe row (l_results(i));
        end loop;
        exit when l_cursor%notfound;
      end loop;
      close l_cursor;
    end if;

    --if some source needs parsing
    if l_to_parse.count > 0 then
      --do we need to parse all of sources
      if l_in_cache.count = 0 then
        l_cursor := get_sources_for_annotations(a_object_owner, a_object_type, a_object_name);
      else
        -- sources need to be filtered by objects to parse
        l_cursor := get_sources_for_annotations(a_object_owner, a_object_type, l_to_parse);
      end if;

      --remove cached annotations data for objects that will be refreshed
      ut_annotation_cache_manager.cleanup_cache(l_to_parse);

      loop
        fetch l_cursor bulk collect into l_names, l_lines limit c_lines_fetch_limit;

        for i in 1 .. l_names.count loop

          if l_names(i) != l_name then
            l_result := ut_annotated_object(a_object_owner, l_name, a_object_type, parse_object_annotations(l_object_lines));
            ut_annotation_cache_manager.update_cache(l_result);
            if l_result.annotations.count > 0 then
              pipe row (l_result);
            end if;
          end if;

          l_name  := l_names(i);
          l_object_lines(l_object_lines.count+1) := l_lines(i);

        end loop;
        exit when l_cursor%notfound;

      end loop;

      if l_name is not null then
        l_result := ut_annotated_object(a_object_owner, l_name, a_object_type, parse_object_annotations(l_object_lines));
        ut_annotation_cache_manager.update_cache(l_result);
        if l_result.annotations.count > 0 then
          pipe row (l_result);
        end if;
      end if;

      close l_cursor;
    end if;

  end;

end ut_annotation_parser;
/
