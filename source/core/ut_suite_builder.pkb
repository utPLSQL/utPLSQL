create or replace package body ut_suite_builder is
  /*
  utPLSQL - Version 3
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

  subtype t_annotation_text     is varchar2(4000);
  subtype t_annotation_name     is varchar2(4000);
  subtype t_object_name         is varchar2(500);
  subtype t_annotation_position is binary_integer;

  gc_suite                       constant t_annotation_name := 'suite';
  gc_suitepath                   constant t_annotation_name := 'suitepath';
  gc_test                        constant t_annotation_name := 'test';
  gc_disabled                    constant t_annotation_name := 'disabled';
  gc_displayname                 constant t_annotation_name := 'displayname';
  gc_beforeall                   constant t_annotation_name := 'beforeall';
  gc_beforeeach                  constant t_annotation_name := 'beforeeach';
  gc_beforetest                  constant t_annotation_name := 'beforetest';
  gc_afterall                    constant t_annotation_name := 'afterall';
  gc_aftereach                   constant t_annotation_name := 'aftereach';
  gc_aftertest                   constant t_annotation_name := 'aftertest';
  gc_throws                      constant t_annotation_name := 'throws';
  gc_rollback                    constant t_annotation_name := 'rollback';
  gc_context                     constant t_annotation_name := 'context';
  gc_endcontext                  constant t_annotation_name := 'endcontext';

  gc_placeholder                 constant varchar2(3) := '\\%';

  --list of annotation texts for a given annotation indexed by annotation position:
  --This would hold: ('some', 'other') for a single annotation name recurring in a single procedure example
  --  --%beforetest(some)
  --  --%beforetest(other)
  --  --%test(some test with two before test procedures)
  --  procedure some_test ...
  -- when you'd like to have two beforetest procedures executed in a single test
  type tt_annotation_texts is table of t_annotation_text index by t_annotation_position;

  type tt_procedure_annotations is table of tt_annotation_texts index by t_annotation_name;

  --holds information about
  --   package level annotation
  -- or
  --   procedure and annotations associated with the procedure
  type t_package_annotation is record(
    text                  t_annotation_text,
    name                  t_annotation_name,
    procedure_name        t_object_name,
    procedure_annotations tt_procedure_annotations
  );

  --holds a list of package and procedure level annotations indexed (order) by position.
  --procedure level annotations are grouped under procedure name 
  type tt_package_annotations is table of t_package_annotation index by t_annotation_position;

  --holds all annotations for object
  type t_package_annotations_info is record(
    owner         t_object_name,
    name          t_object_name,
    annotations   tt_package_annotations
  );

  --list of all package level annotation positions for a given annotaion name
  type tt_package_annot_positions is table of boolean index by t_annotation_position;
  --index used to lookup package level annotations by package-level annotation name
  type tt_annotations_index   is table of tt_package_annot_positions index by t_annotation_name;


  -----------------------------------------------
  --- Conversion of annotations for processing
  -----------------------------------------------
  function get_procedure_annotations(a_annotations ut_annotations, a_index in out nocopy binary_integer) return tt_procedure_annotations is
    l_result         tt_procedure_annotations;
    l_index          binary_integer := a_index;
    l_annotation_pos binary_integer;
    function is_last_annotation_for_proc(a_annotations ut_annotations, a_index binary_integer) return boolean is
    begin
      return a_index = a_annotations.count or a_annotations(a_index).subobject_name != nvl(a_annotations(a_index+1).subobject_name, ' ');
    end;
  begin
    loop
      l_annotation_pos := a_annotations(a_index).position;
      l_result(a_annotations(a_index).name)(l_annotation_pos) := a_annotations(a_index).text;
      exit when is_last_annotation_for_proc(a_annotations, a_index);
      a_index := a_annotations.next(a_index);
    end loop;
    return l_result;
  end;

  function convert_package_annotations(a_object ut_annotated_object) return t_package_annotations_info is
    l_result         t_package_annotations_info;
    l_annotation_no  binary_integer;
    l_annotation_pos binary_integer;
  begin
    l_result.owner := a_object.object_owner;
    l_result.name  := lower(trim(a_object.object_name));
    l_annotation_no := a_object.annotations.first;
    while l_annotation_no is not null loop
      l_annotation_pos := a_object.annotations(l_annotation_no).position;
      if a_object.annotations(l_annotation_no).subobject_name is null then
        l_result.annotations(l_annotation_pos).name := a_object.annotations(l_annotation_no).name;
        l_result.annotations(l_annotation_pos).text := a_object.annotations(l_annotation_no).text;
      else
        l_result.annotations(l_annotation_pos).procedure_name        := lower(trim(a_object.annotations(l_annotation_no).subobject_name));
        l_result.annotations(l_annotation_pos).procedure_annotations := get_procedure_annotations(a_object.annotations, l_annotation_no);
      end if;
      l_annotation_no := a_object.annotations.next(l_annotation_no);
    end loop;
    return l_result;
  end;

  function build_annotation_index(a_annotations tt_package_annotations ) return tt_annotations_index is
    l_result         tt_annotations_index;
    l_annotation_pos binary_integer;
  begin
    l_annotation_pos := a_annotations.first;
    while l_annotation_pos is not null loop
      if a_annotations( l_annotation_pos ).name is not null then
        l_result(a_annotations( l_annotation_pos ).name)( l_annotation_pos ) := true;
      end if;
      l_annotation_pos := a_annotations.next( l_annotation_pos );
    end loop;
    return l_result;
  end;

  procedure delete_from_annotation_index(
    a_index in out nocopy tt_annotations_index,
    a_start_pos t_annotation_position,
    a_end_pos t_annotation_position
  ) is
    l_idx t_annotation_name;
  begin
    l_idx :=  a_index.first;
    while l_idx is not null loop
      a_index( l_idx ).delete( a_start_pos, a_end_pos);
      if a_index( l_idx ).count = 0 then
        a_index.delete( l_idx );
      end if;
      l_idx := a_index.next( l_idx );
    end loop;
  end;

  -----------------------------------------------
  -- Processing annotations
  -----------------------------------------------

  procedure add_annotation_warning(
    a_suite          in out nocopy ut_suite_item,
    a_annotation     t_annotation_name,
    a_message        varchar2,
    a_line_no        binary_integer,
    a_procedure_name t_object_name := null
  ) is
    l_object_name varchar2(1000);
  begin
    l_object_name := upper( a_suite.object_owner || '.' || a_suite.object_name );
    if a_procedure_name is not null then
      l_object_name := l_object_name || upper( '.' || a_procedure_name );
    end if;
    a_suite.put_warning(
        replace(a_message,'%%%','"--%'||a_annotation||'"') || ' Annotation ignored.'
        || chr( 10 ) || 'at "' || l_object_name || '", line ' || a_line_no
    );
  end;

  function get_rollback_type(a_rollback_type_name varchar2) return ut_utils.t_rollback_type is
    l_rollback_type ut_utils.t_rollback_type;
  begin
    l_rollback_type :=
      case lower(a_rollback_type_name)
        when 'manual' then ut_utils.gc_rollback_manual
        when 'auto' then ut_utils.gc_rollback_auto
      end;
     return l_rollback_type;
  end;

  function check_exception_type(a_exception_name in varchar2) return varchar2 is
      l_a varchar2(250);
      l_b varchar2(250);
      l_c varchar2(250);
      l_dblink varchar2(250);
      l_next_pos pls_integer;
      l_exception_type varchar2(50) := 'NUMBER';
    begin
     
      begin
        --check if it is a number first
        dbms_utility.name_tokenize(a_exception_name, l_a, l_b, l_c, l_dblink, l_next_pos);
        --check if it is a predefined exception
        begin
          execute immediate 'begin null; exception when '||a_exception_name||' then null; end;';
          l_exception_type := 'NAMED';
        exception
          when others then
            if dbms_utility.format_error_stack() like '%PLS-00485%' then
              execute immediate 'declare x positiven := -('||a_exception_name||'); begin null; end;';
              l_exception_type := 'NUMBER';
            else
              l_exception_type := 'UNKNOWN';
            end if;
        end;
      exception when others then
       null;
      end;
      return l_exception_type;
   end;


  function get_exception_number (a_exception_var in varchar2) return number is
    l_exception_no number;
    l_exception_type varchar2(50);
  begin
   l_exception_type := check_exception_type(a_exception_var);
   if l_exception_type = 'NUMBER' then
   execute immediate 'declare
                        l_exception number;
                      begin
                        :l_exception := '||a_exception_var||';
                      exception
                        when others then
                         :l_exception := null;
                      end;' using in out l_exception_no;
                      
    elsif l_exception_type = 'NAMED' then 
     execute immediate 'begin
                          raise '||a_exception_var||';
                       exception
                         when others then
                           :l_exception := sqlcode;
                       end;' using in out l_exception_no;
    end if;
    return l_exception_no;                             
  end;  

  function is_valid_qualified_name (a_name varchar2) return boolean is
   l_name varchar2(500);
  begin
    l_name:=dbms_assert.qualified_sql_name(a_name);
    return true;
  exception when others then
    return false;
  end;
  
  function build_exception_numbers_list(a_annotation_text in varchar2) return ut_integer_list is
    l_throws_list           ut_varchar2_list;
    l_exception_number_list ut_integer_list := ut_integer_list();
    l_regexp_for_excep_nums varchar2(30) := '^-?[[:digit:]]{1,5}$';
  begin
    /*the a_expected_error_codes is converted to a ut_varchar2_list after that is trimmed and filtered to left only valid exception numbers*/
    l_throws_list := ut_utils.trim_list_elements(ut_utils.string_to_table(a_annotation_text, ',', 'Y'));
    
    for i in 1..l_throws_list.count 
    loop
      /** 
      * First check if its a valid qualified name and if so try to resolve to number
      * If not check if it matches the ora regex number pattern.
      */
      if is_valid_qualified_name(l_throws_list(i)) then 
       l_throws_list(i) := get_exception_number(l_throws_list(i));
      else
        l_throws_list(i) := l_throws_list(i);
      end if;
    end loop;
    
    l_throws_list := ut_utils.filter_list( ut_utils.trim_list_elements(l_throws_list), l_regexp_for_excep_nums);

    l_exception_number_list.extend(l_throws_list.count);
    for i in 1 .. l_throws_list.count loop
      l_exception_number_list(i) := l_throws_list(i);
    end loop;
    return l_exception_number_list;
  end;

  procedure add_to_throws_numbers_list(
    a_list in out nocopy ut_integer_list,
    a_throws_ann_text tt_annotation_texts
  ) is
    l_annotation_pos binary_integer;
  begin
    a_list := ut_integer_list();
    l_annotation_pos := a_throws_ann_text.first;
    while l_annotation_pos is not null loop
      a_list := a_list multiset union build_exception_numbers_list( a_throws_ann_text(l_annotation_pos));
      l_annotation_pos := a_throws_ann_text.next(l_annotation_pos);
    end loop;
  end;

  procedure add_to_list(
    a_executables     in out nocopy ut_executables,
    a_owner           varchar2,
    a_package_name    varchar2,
    a_procedure_name  varchar2,
    a_executable_type ut_utils.t_executable_type
  ) is
    begin
      if a_executables is null then
        a_executables := ut_executables();
      end if;
      a_executables.extend;
      a_executables(a_executables.last) := ut_executable(a_owner, a_package_name, a_procedure_name, a_executable_type);
  end;

  procedure add_all_to_list(
    a_executables in out nocopy ut_executables,
    a_owner            varchar2,
    a_package_name     varchar2,
    a_annotation_texts tt_annotation_texts,
    a_event_name       ut_utils.t_event_name
  ) is
    l_annotation_pos   binary_integer;
    begin
      l_annotation_pos := a_annotation_texts.first;
      while l_annotation_pos is not null loop
        add_to_list(a_executables, a_owner, a_package_name, a_annotation_texts(l_annotation_pos), a_event_name );
        l_annotation_pos := a_annotation_texts.next( l_annotation_pos);
      end loop;
    end;

  procedure warning_on_duplicate_annot(
    a_suite          in out nocopy ut_suite_item,
    a_annotations     tt_annotations_index,
    a_for_annotation varchar2
  ) is
    l_annotation_name t_annotation_name;
    l_line_no           binary_integer;
  begin
    if a_annotations.exists(a_for_annotation) then
      if a_annotations(a_for_annotation).count > 1 then
        --start from second occurrence of annotation
        l_line_no := a_annotations(a_for_annotation).next( a_annotations(a_for_annotation).first );
        while l_line_no is not null loop
          add_annotation_warning( a_suite, a_for_annotation, 'Duplicate annotation %%%.', l_line_no );
          l_line_no := a_annotations(a_for_annotation).next( l_line_no );
        end loop;
      end if;
    end if;
  end;

  procedure warning_on_duplicate_annot(
    a_suite          in out nocopy ut_suite_item,
    a_procedure_name  t_object_name,
    a_annotations     tt_procedure_annotations,
    a_for_annotation  varchar2
  ) is
    l_annotation_name t_annotation_name;
    l_line_no           binary_integer;
    begin
      if a_annotations.exists(a_for_annotation) then
        if a_annotations(a_for_annotation).count > 1 then
          --start from second occurrence of annotation
          l_line_no := a_annotations(a_for_annotation).next( a_annotations(a_for_annotation).first );
          while l_line_no is not null loop
            add_annotation_warning( a_suite, a_for_annotation, 'Duplicate annotation %%%.', l_line_no, a_procedure_name );
            l_line_no := a_annotations(a_for_annotation).next( l_line_no );
          end loop;
        end if;
      end if;
    end;

  procedure warning_bad_annot_combination(
    a_suite               in out nocopy ut_suite_item,
    a_procedure_name      t_object_name,
    a_proc_annotations    tt_procedure_annotations,
    a_for_annotation      varchar2,
    a_invalid_annotations ut_varchar2_list
  ) is
    l_annotation_name t_annotation_name;
    l_warning         varchar2(32767);
    l_line_no           binary_integer;
  begin
    l_annotation_name := a_proc_annotations.first;
    while l_annotation_name is not null loop
      if l_annotation_name member of a_invalid_annotations then
        l_line_no := a_proc_annotations(l_annotation_name).first;
        while l_line_no is not null loop
          add_annotation_warning(
              a_suite, l_annotation_name, 'Annotation %%% cannot be used with "--%'|| a_for_annotation || '".',
              l_line_no, a_procedure_name
          );
          l_line_no := a_proc_annotations(l_annotation_name).next(l_line_no);
        end loop;
      end if;
      l_annotation_name := a_proc_annotations.next(l_annotation_name);
    end loop;
  end;

  procedure add_test(
    a_suite          in out nocopy ut_suite,
    a_procedure_name varchar2,
    a_annotations    tt_procedure_annotations
  ) is
    l_test             ut_test;
    l_annotation_texts tt_annotation_texts;
    l_annotation_pos   binary_integer;
  begin
    l_test := ut_test(a_suite.object_owner, a_suite.object_name, a_procedure_name);

    if a_annotations.exists(gc_displayname) then
      l_annotation_texts := a_annotations(gc_displayname);
      --take the last definition if more than one was provided
      l_test.description := l_annotation_texts(l_annotation_texts.first);
      --TODO if more than one - warning
    else
      l_test.description := a_annotations(gc_test)(a_annotations(gc_test).first);
    end if;
    l_test.path := a_suite.path ||'.'||a_procedure_name;

    if a_annotations.exists(gc_rollback) then
      l_annotation_texts := a_annotations(gc_rollback);
      l_test.rollback_type := get_rollback_type(l_annotation_texts(l_annotation_texts.first));
      if l_test.rollback_type is null then
        add_annotation_warning(
            a_suite, gc_rollback, 'Annotation %%% must be provided with one of values: "auto" or "manual".',
            l_annotation_texts.first, a_procedure_name
        );
      end if;
    end if;

    if a_annotations.exists(gc_beforetest) then
      add_all_to_list( l_test.before_test_list, l_test.object_owner, l_test.object_name, a_annotations(gc_beforetest), ut_utils.gc_before_test );
    end if;
    if a_annotations.exists(gc_aftertest) then
      add_all_to_list( l_test.after_test_list, l_test.object_owner, l_test.object_name, a_annotations(gc_aftertest), ut_utils.gc_after_test );
    end if;
    if a_annotations.exists(gc_throws) then
      add_to_throws_numbers_list(l_test.expected_error_codes, a_annotations(gc_throws));
    end if;
    l_test.disabled_flag := ut_utils.boolean_to_int(a_annotations.exists(gc_disabled));

    a_suite.add_item(l_test);
  end;

  procedure update_before_after_list(
    a_suite in out nocopy ut_logical_suite,
    a_before_each_list ut_executables,
    a_after_each_list ut_executables
  ) is
    l_test      ut_test;
    l_context   ut_logical_suite;
  begin
    if a_suite.items is not null then
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of (ut_test) then
          l_test := treat( a_suite.items(i) as ut_test);
          l_test.before_each_list := coalesce(a_before_each_list,ut_executables()) multiset union all l_test.before_each_list;
          l_test.after_each_list := l_test.after_each_list multiset union all coalesce(a_after_each_list,ut_executables());
          a_suite.items(i) := l_test;
        elsif a_suite.items(i) is of (ut_logical_suite) then
          l_context := treat(a_suite.items(i) as ut_logical_suite);
          update_before_after_list(l_context, a_before_each_list, a_after_each_list);
          a_suite.items(i) := l_context;
        end if;
      end loop;
    end if;
  end;

  procedure add_annotated_procedure(
    a_procedure_name   t_object_name,
    a_proc_annotations tt_procedure_annotations,
    a_suite            in out nocopy ut_suite,
    a_before_each_list in out nocopy ut_executables,
    a_after_each_list  in out nocopy ut_executables
  ) is
  begin
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_test);
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_displayname);
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_rollback);
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_beforeall);
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_beforeeach);
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_afterall);
    warning_on_duplicate_annot(a_suite, a_procedure_name, a_proc_annotations, gc_aftereach);
    
    if a_proc_annotations.exists(gc_test) then
      add_test( a_suite, a_procedure_name, a_proc_annotations);

      warning_bad_annot_combination(
        a_suite, a_procedure_name, a_proc_annotations, gc_test,
        ut_varchar2_list(gc_beforeeach, gc_aftereach, gc_beforeall, gc_afterall)
      );

    else
      if a_proc_annotations.exists(gc_beforeeach) then
        add_to_list( a_before_each_list, a_suite.object_owner, a_suite.object_name, a_procedure_name, ut_utils.gc_before_each );
        --TODO add warning if annotation has text - text ignored
      end if;
      if a_proc_annotations.exists(gc_aftereach) then
        add_to_list( a_after_each_list, a_suite.object_owner, a_suite.object_name, a_procedure_name, ut_utils.gc_after_each );
        --TODO add warning if annotation has text - text ignored
      end if;
      if a_proc_annotations.exists(gc_beforeall) then
        add_to_list( a_suite.before_all_list, a_suite.object_owner, a_suite.object_name, a_procedure_name, ut_utils.gc_before_all );
        --TODO add warning if annotation has text - text ignored
      end if;
      if a_proc_annotations.exists(gc_afterall) then
        add_to_list( a_suite.after_all_list, a_suite.object_owner, a_suite.object_name, a_procedure_name, ut_utils.gc_after_all );
        --TODO add warning if annotation has text - text ignored
      end if;
    end if;
  end;

  procedure add_annotated_procedures(
    a_annotations tt_package_annotations,
    a_suite in out nocopy ut_suite,
    a_before_each_list out ut_executables,
    a_after_each_list out ut_executables
  ) is
    l_position t_annotation_position;
  begin
    a_before_each_list := ut_executables();
    a_after_each_list := ut_executables();
    l_position := a_annotations.first;
    while l_position is not null loop
      if a_annotations(l_position).procedure_name is not null then
        add_annotated_procedure(
          a_annotations(l_position).procedure_name,
          a_annotations(l_position).procedure_annotations,
          a_suite,
          a_before_each_list,
          a_after_each_list
        );
      end if;
      l_position := a_annotations.next( l_position);
    end loop;
  end;

  procedure populate_suite_contents(
    a_suite              in out nocopy ut_suite,
    a_annotations        tt_package_annotations,
    a_package_ann_index  tt_annotations_index,
    a_context_name       t_object_name := null
  ) is
    l_before_each_list   ut_executables;
    l_after_each_list    ut_executables;
    l_rollback_type      ut_utils.t_rollback_type;
    l_annotation_text    varchar2(32767);
    l_object_name        t_object_name;
  begin
    if a_context_name is not null then
      l_object_name := a_suite.object_name||'.'||a_context_name;
    else
      l_object_name := a_suite.object_name;
    end if;
    if a_package_ann_index.exists(gc_suitepath) then
      l_annotation_text := trim(a_annotations(a_package_ann_index(gc_suitepath).first).text);
      if l_annotation_text is not null then
        if regexp_like(l_annotation_text,'^((\w|[$#])+\.)*(\w|[$#])+$') then
          a_suite.path := l_annotation_text||'.'||l_object_name;
        else
          add_annotation_warning(
            a_suite, gc_suitepath||'('||l_annotation_text||')',
            'Invalid path value in annotation %%%.', a_package_ann_index(gc_suitepath).first
          );
        end if;
      else
        add_annotation_warning(
          a_suite, gc_suitepath, '%%% annotation requires a non-empty parameter value.',
          a_package_ann_index(gc_suitepath).first
        );
      end if;
      warning_on_duplicate_annot(a_suite, a_package_ann_index, gc_suitepath);
    end if;
    a_suite.path := lower(coalesce(a_suite.path, l_object_name));

    if a_package_ann_index.exists(gc_displayname) then
      l_annotation_text := trim(a_annotations(a_package_ann_index(gc_displayname).first).text);
      if l_annotation_text is not null then
        a_suite.description := l_annotation_text;
      else
        add_annotation_warning(
            a_suite, gc_displayname, '%%% annotation requires a non-empty parameter value.',
            a_package_ann_index(gc_displayname).first
        );
      end if;
      warning_on_duplicate_annot(a_suite, a_package_ann_index, gc_displayname);
    end if;

    if a_package_ann_index.exists(gc_rollback) then
      l_rollback_type := get_rollback_type(a_annotations(a_package_ann_index(gc_rollback).first).text);
      if l_rollback_type is null then
        add_annotation_warning(
            a_suite, gc_rollback, '%%% annotation requires one of values as parameter: "auto" or "manual".',
            a_package_ann_index(gc_rollback).first
        );
      end if;
      warning_on_duplicate_annot(a_suite, a_package_ann_index, gc_rollback);
    end if;

    a_suite.disabled_flag := ut_utils.boolean_to_int(a_package_ann_index.exists(gc_disabled));

    --process procedure annotations for suite
    add_annotated_procedures(a_annotations, a_suite, l_before_each_list, l_after_each_list);

    a_suite.set_rollback_type(l_rollback_type);
    update_before_after_list(a_suite, l_before_each_list, l_after_each_list);
  end;


  procedure add_suite_contexts(
    a_suite              in out nocopy ut_suite,
    a_annotations        in out nocopy tt_package_annotations,
    a_package_ann_index  in out nocopy tt_annotations_index
  ) is
    l_context_pos        t_annotation_position;
    l_end_context_pos    t_annotation_position;
    l_package_ann_index  tt_annotations_index;
    l_annotations        tt_package_annotations;
    l_suite              ut_suite;
    l_context_no         binary_integer := 1;

    function get_endcontext_position(
      a_context_ann_pos   t_annotation_position,
      a_package_ann_index in out nocopy tt_annotations_index
    ) return t_annotation_position is
      l_result t_annotation_position;
    begin
      if a_package_ann_index.exists(gc_endcontext) then
        l_result := a_package_ann_index(gc_endcontext).first;
        while l_result <= a_context_ann_pos loop
          --remove invalid endcontext
          delete_from_annotation_index(a_package_ann_index, l_result, l_result);
          --remove the bad endcontext from index
          l_result := a_package_ann_index(gc_endcontext).next(l_result);
        end loop;
      end if;
      return l_result;
    end;

    function get_annotations_in_context(
      a_annotations        tt_package_annotations,
      a_context_pos        t_annotation_position,
      a_end_context_pos    t_annotation_position
    ) return tt_package_annotations is
      l_annotations        tt_package_annotations;
      l_position           t_annotation_position;
    begin
      l_position := a_context_pos;
      while l_position is not null and l_position <= a_end_context_pos loop
        l_annotations(l_position) := a_annotations(l_position);
        l_position := a_annotations.next(l_position);
      end loop;
      return l_annotations;
    end;

  begin
    if not a_package_ann_index.exists(gc_context) then
      return;
    end if;
    l_context_pos := a_package_ann_index(gc_context).first;
    while l_context_pos is not null loop
      l_end_context_pos := get_endcontext_position(l_context_pos, a_package_ann_index);
      if l_end_context_pos is null then
        exit;
      end if;

      --create a sub-set of annotations to process as sub-suite (context)
      l_annotations       := get_annotations_in_context(a_annotations, l_context_pos, l_end_context_pos);
      l_package_ann_index := build_annotation_index(l_annotations);

      l_suite := ut_suite(a_suite.object_owner, a_suite.object_name, gc_context||'_'||l_context_no);

      l_suite.description := l_annotations(l_package_ann_index(gc_context).first).text;
      l_suite.description := l_annotations(l_context_pos).text;
      warning_on_duplicate_annot( l_suite, l_package_ann_index, gc_suite );

      populate_suite_contents( l_suite, l_annotations, l_package_ann_index, gc_context||'_'||l_context_no );

      a_suite.add_item(l_suite);

      -- remove annotations within context after processing them
      a_annotations.delete(l_context_pos, l_end_context_pos);
      delete_from_annotation_index(a_package_ann_index, l_context_pos, l_end_context_pos);

      if a_package_ann_index.exists(gc_context) then
        l_context_pos := a_package_ann_index(gc_context).next(l_context_pos);
      else
        l_context_pos := null;
      end if;
      l_context_no := l_context_no + 1;
    end loop;
  end;

  procedure warning_on_incomplete_context(
    a_suite              in out nocopy ut_suite,
    a_annotations        tt_package_annotations,
    a_package_ann_index  tt_annotations_index
  ) is
    l_annotation_pos  t_annotation_position;
    begin
      if a_package_ann_index.exists(gc_context) then
        l_annotation_pos := a_package_ann_index(gc_context).first;
        while l_annotation_pos is not null loop
          add_annotation_warning(
              a_suite, gc_context, 'Invalid annotation %%%. Cannot find following "--%endcontext".',
              l_annotation_pos
          );
          l_annotation_pos := a_package_ann_index(gc_context).next(l_annotation_pos);
        end loop;
      end if;
      if a_package_ann_index.exists(gc_endcontext) then
        l_annotation_pos := a_package_ann_index(gc_endcontext).first;
        while l_annotation_pos is not null loop
          add_annotation_warning(
              a_suite, gc_endcontext, 'Invalid annotation %%%. Cannot find preceding "--%context".',
              l_annotation_pos
          );
          l_annotation_pos := a_package_ann_index(gc_endcontext).next(l_annotation_pos);
        end loop;
      end if;
    end;

  function create_suite(
    a_package_annotations t_package_annotations_info
  ) return ut_logical_suite is
    l_annotations       tt_package_annotations := a_package_annotations.annotations;
    l_package_ann_index tt_annotations_index;
    l_suite              ut_suite;
  begin
    l_package_ann_index   := build_annotation_index(l_annotations);
    if l_package_ann_index.exists(gc_suite) then

      --create an incomplete suite
      l_suite := ut_suite(a_package_annotations.owner, a_package_annotations.name);

      l_suite.description := l_annotations(l_package_ann_index(gc_suite).first).text;
      warning_on_duplicate_annot(l_suite, l_package_ann_index, gc_suite);

      add_suite_contexts( l_suite, l_annotations, l_package_ann_index );
      --by this time all contexts were consumed and l_annotations should not have any context/endcontext annotation in it.
      warning_on_incomplete_context( l_suite, l_annotations, l_package_ann_index );

      populate_suite_contents( l_suite, l_annotations, l_package_ann_index );

    end if;
    return l_suite;
  end;

  function create_suite(a_object ut_annotated_object) return ut_logical_suite is
  begin
    return create_suite( convert_package_annotations(a_object) );
  end create_suite;

  function build_suites_hierarchy(a_suites_by_path tt_schema_suites) return tt_schema_suites is
    l_result            tt_schema_suites;
    l_suite_path        varchar2(4000 char);
    l_parent_path       varchar2(4000 char);
    l_name              varchar2(4000 char);
    l_suites_by_path    tt_schema_suites;
  begin
    l_suites_by_path := a_suites_by_path;
    --were iterating in reverse order of the index by path table
    -- so the first paths will be the leafs of hierarchy and next will their parents
    l_suite_path  := l_suites_by_path.last;
    ut_utils.debug_log('Input suites to process = '||l_suites_by_path.count);

    while l_suite_path is not null loop
      l_parent_path := substr( l_suite_path, 1, instr(l_suite_path,'.',-1)-1);
      ut_utils.debug_log('Processing l_suite_path = "'||l_suite_path||'", l_parent_path = "'||l_parent_path||'"');
      --no parent => I'm a root element
      if l_parent_path is null then
        ut_utils.debug_log('  suite "'||l_suite_path||'" is a root element - adding to return list.');
        l_result(l_suite_path) := l_suites_by_path(l_suite_path);
      -- not a root suite - need to add it to a parent suite
      else
        --parent does not exist and needs to be added
        if not l_suites_by_path.exists(l_parent_path) then
          l_name  := substr( l_parent_path, instr(l_parent_path,'.',-1)+1);
          ut_utils.debug_log('  Parent suite "'||l_parent_path||'" not found in the list - Adding suite "'||l_name||'"');
          l_suites_by_path(l_parent_path) :=
            ut_logical_suite(
              a_object_owner => l_suites_by_path(l_suite_path).object_owner,
              a_object_name => l_name, a_name => l_name, a_path => l_parent_path
            );
        else
          ut_utils.debug_log('  Parent suite "'||l_parent_path||'" found in list of suites');
        end if;
        ut_utils.debug_log('  adding suite "'||l_suite_path||'" to "'||l_parent_path||'" items');
        l_suites_by_path(l_parent_path).add_item( l_suites_by_path(l_suite_path) );
      end if;
      l_suite_path := l_suites_by_path.prior(l_suite_path);
    end loop;
    ut_utils.debug_log(l_result.count||' root suites created.');
    return l_result;
  end;

  function build_suites(a_annotated_objects sys_refcursor) return t_schema_suites_info is
    l_suite             ut_logical_suite;
    l_annotated_objects ut_annotated_objects;
    l_all_suites        tt_schema_suites;
    l_result            t_schema_suites_info;
  begin
    fetch a_annotated_objects bulk collect into l_annotated_objects;
    close a_annotated_objects;

    for i in 1 .. l_annotated_objects.count loop
      l_suite := create_suite(l_annotated_objects(i));
      if l_suite is not null then
        l_all_suites(l_suite.path) := l_suite;
        l_result.suite_paths(l_suite.object_name) := l_suite.path;
      end if;
    end loop;

    --build hierarchical structure of the suite
    -- Restructure single-dimension list into hierarchy of suites by the value of %suitepath attribute value
    l_result.schema_suites := build_suites_hierarchy(l_all_suites);

    return l_result;
  end;

  function build_schema_suites(a_owner_name varchar2) return t_schema_suites_info is
    l_annotations_cursor sys_refcursor;
  begin
    -- form the single-dimension list of suites constructed from parsed packages
    open l_annotations_cursor for
      q'[select value(x)
          from table(
            ]'||ut_utils.ut_owner||q'[.ut_annotation_manager.get_annotated_objects(:a_owner_name, 'PACKAGE')
          )x ]'
      using a_owner_name;

    return build_suites(l_annotations_cursor);
  end;

end ut_suite_builder;
/
