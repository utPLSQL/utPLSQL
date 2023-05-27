create or replace package body ut_annotation_parser as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  type tt_comment_list is table of varchar2(32767) index by binary_integer;

  gc_annotation_qualifier        constant varchar2(1) := '%';
  gc_annot_comment_pattern       constant varchar2(30) := '^( |'||chr(09)||')*-- *('||gc_annotation_qualifier||'.*?)$'; -- chr(09) is a tab character
  gc_comment_replacer_patter     constant varchar2(50) := '{COMMENT#%N%}';
  gc_comment_replacer_regex_ptrn constant varchar2(25) := '{COMMENT#(\d+)}';
  gc_regexp_identifier           constant varchar2(50) := '[[:alpha:]][[:alnum:]$#_]*';
  gc_annotation_block_pattern    constant varchar2(200) := '(({COMMENT#.+}'||chr(10)||')+)( |'||chr(09)||')*(procedure|function)\s+(' ||
                                                           gc_regexp_identifier || ')';
  gc_annotation_pattern          constant varchar2(50) := gc_annotation_qualifier || gc_regexp_identifier || '[ '||chr(9)||']*(\(.*?\)\s*?$)?';


  procedure add_annotation(
    a_annotations in out nocopy ut_annotations,
    a_position positiven,
    a_comment varchar2,
    a_subobject_name varchar2 := null
  ) is
    l_annotation_str   varchar2(32767);
    l_annotation_text  varchar2(32767);
    l_annotation_name  varchar2(1000);
  begin
    -- strip everything except the annotation itself (spaces and others)
    l_annotation_str := regexp_substr(a_comment, gc_annotation_pattern, 1, 1, modifier => 'i');
    if l_annotation_str is not null then

      -- get the annotation name and it's parameters if present
      l_annotation_name := lower(regexp_substr(l_annotation_str ,'%(' || gc_regexp_identifier || ')', subexpression => 1));
      l_annotation_text := trim(regexp_substr(l_annotation_str, '\((.*?)\)\s*$', subexpression => 1));

      a_annotations.extend;
      a_annotations( a_annotations.last) :=
        ut_annotation(a_position, l_annotation_name, l_annotation_text, a_subobject_name);
    end if;
  end;

  procedure delete_processed_comments( a_comments in out nocopy tt_comment_list, a_annotations ut_annotations ) is
    l_loop_index       binary_integer := 1;
  begin
    l_loop_index := a_annotations.first;
    while l_loop_index is not null loop
      a_comments.delete( a_annotations(l_loop_index).position );
      l_loop_index := a_annotations.next( l_loop_index );
    end loop;
  end;

  procedure add_annotations(
    a_annotations in out nocopy ut_annotations,
    a_source varchar2,
    a_comments tt_comment_list,
    a_subobject_name varchar2 := null
  ) is
    l_loop_index       binary_integer := 1;
    l_annotation_index binary_integer;
  begin
    -- loop while there are unprocessed comment blocks
    while 0 != nvl(regexp_instr(srcstr        => a_source
                               ,pattern       => gc_comment_replacer_regex_ptrn
                               ,occurrence    => l_loop_index
                               ,subexpression => 1)
                  ,0) loop

      -- define index of the comment block and get it's content from cache
      l_annotation_index := regexp_substr( a_source ,gc_comment_replacer_regex_ptrn ,1 ,l_loop_index ,subexpression => 1);
      add_annotation( a_annotations, l_annotation_index, a_comments( l_annotation_index ), a_subobject_name );
      l_loop_index := l_loop_index + 1;
    end loop;

  end add_annotations;

  procedure add_procedure_annotations(a_annotations in out nocopy ut_annotations, a_source clob, a_comments in out nocopy tt_comment_list) is
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
                                      ,pattern    => gc_annotation_block_pattern
                                      ,occurrence => 1
                                      ,modifier   => 'i'
                                      ,position   => l_annot_proc_ind);
      exit when l_annot_proc_ind = 0;

      --get the annotations with procedure name
      l_annot_proc_block := regexp_substr(srcstr     => a_source
                                         ,pattern    => gc_annotation_block_pattern
                                         ,position   => l_annot_proc_ind
                                         ,occurrence => 1
                                         ,modifier   => 'i');

      --extract the annotations
      l_proc_comments := trim(regexp_substr(srcstr        => l_annot_proc_block
                                           ,pattern       => gc_annotation_block_pattern
                                           ,modifier      => 'i'
                                           ,subexpression => 1));
      --extract the procedure name
      l_proc_name     := trim(regexp_substr(srcstr        => l_annot_proc_block
                                           ,pattern       => gc_annotation_block_pattern
                                           ,modifier      => 'i'
                                           ,subexpression => 5));

      -- parse the comment block for the syntactically correct annotations and store them as an array
      add_annotations(a_annotations, l_proc_comments, a_comments, l_proc_name);

      l_annot_proc_ind := instr(a_source, ';', l_annot_proc_ind + length(l_annot_proc_block) );
    end loop;
  end add_procedure_annotations;

  function extract_and_replace_comments(a_source in out nocopy clob) return tt_comment_list is
    l_comments         tt_comment_list;
    l_comment_pos      binary_integer;
    l_comment_line     binary_integer;
    l_comment_replacer varchar2(50);
    l_source           clob := a_source;
  begin
    l_comment_pos := 1;
    loop

      l_comment_pos := regexp_instr(srcstr     => a_source
                                   ,pattern    => gc_annot_comment_pattern
                                   ,occurrence => 1
                                   ,modifier   => 'm'
                                   ,position   => l_comment_pos);

      exit when l_comment_pos = 0;

      -- position index is shifted by 1 because gc_annot_comment_pattern contains ^ as first sign
      -- but after instr index already points to the char on that line
      l_comment_pos := l_comment_pos-1;
      l_comment_line := length(substr(a_source,1,l_comment_pos))-length(replace(substr(a_source,1,l_comment_pos),chr(10)))+1;
      l_comments(l_comment_line) := trim(regexp_substr(srcstr        => a_source
                                                            ,pattern       => gc_annot_comment_pattern
                                                            ,occurrence    => 1
                                                            ,position      => l_comment_pos
                                                            ,modifier      => 'm'
                                                            ,subexpression => 2));

      l_comment_replacer := replace(gc_comment_replacer_patter, '%N%', l_comment_line);

      l_source    := regexp_replace(srcstr     => a_source
                                   ,pattern    => gc_annot_comment_pattern
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

  ------------------------------------------------------------
  --public definitions
  ------------------------------------------------------------

  function parse_object_annotations(a_source clob) return ut_annotations is
    l_source           clob := a_source;
    l_comments         tt_comment_list;
    l_annotations      ut_annotations := ut_annotations();
    l_result           ut_annotations;
    l_comment_index    positive;
  begin

     l_source := ut_utils.replace_multiline_comments(l_source);

    -- replace all single line comments with {COMMENT#12} element and store it's content for easier processing
    -- this call modifies l_source
    l_comments := extract_and_replace_comments(l_source);

    add_procedure_annotations(l_annotations, l_source, l_comments);

    delete_processed_comments(l_comments, l_annotations);

    --at this point, only the comments not related to procedures are left, so we process them all as top-level
    l_comment_index := l_comments.first;
    while l_comment_index is not null loop
      add_annotation( l_annotations, l_comment_index, l_comments( l_comment_index ) );
      l_comment_index := l_comments.next(l_comment_index);
    end loop;

    dbms_lob.freetemporary(l_source);

    select /*+ no_parallel */ value(x) bulk collect into l_result from table(l_annotations) x order by x.position;

    return l_result;
  end parse_object_annotations;

  function parse_object_annotations(a_source_lines dbms_preprocessor.source_lines_t, a_object_type varchar2) return ut_annotations is
    l_processed_lines dbms_preprocessor.source_lines_t;
    l_source          clob;
    l_annotations     ut_annotations := ut_annotations();
    ex_package_is_wrapped exception;
    pragma exception_init(ex_package_is_wrapped, -24241);
    source_text_is_empty exception;
    pragma exception_init(source_text_is_empty, -24236);
  begin
    if a_source_lines.count > 0 then
      --convert to post-processed source clob
      begin
        --get post-processed source
        if a_object_type = 'TYPE' then
          l_processed_lines := a_source_lines;
        else
          l_processed_lines := sys.dbms_preprocessor.get_post_processed_source(a_source_lines);
        end if;
        --convert to clob
        for i in 1..l_processed_lines.count loop
          ut_utils.append_to_clob(l_source, replace(l_processed_lines(i), chr(13)||chr(10), chr(10)));
        end loop;
        --parse annotations
        l_annotations := parse_object_annotations(l_source);
        dbms_lob.freetemporary(l_source);
      exception
        when ex_package_is_wrapped or source_text_is_empty then
          null;
      end;
    end if;
    return l_annotations;
  end;

end;
/
