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

    -- printing out parsed structure for debugging
    $if $$ut_trace $then
      print_parse_results(l_result);
    $end
    return l_result;
  end parse_package_annotations;

  ------------------------------
  --public definitions

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
