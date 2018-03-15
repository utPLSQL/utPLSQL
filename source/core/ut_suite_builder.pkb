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
  subtype t_procedure_name      is varchar2(500);
  subtype t_annotation_position is binary_integer;


  --list of annotation texts for a given annotation indexed by annotation position:
  --This would hold: ('some', 'other') for a single annotation name recurring in a single procedure example
  --  --%beforetest(some)
  --  --%beforetest(other)
  --  --%test(some test with two before test procedures)
  --  procedure some_test ...
  -- when you'd like to have two beforetest procedures executed in a single test
  type tt_annotation_texts is table of t_annotation_text index by t_annotation_position;

  type tt_annotations_by_name is table of tt_annotation_texts index by t_annotation_name;

  type t_object_annotation is record(
    text                  varchar2(4000),
    name                  varchar2(4000),
    procedure_name        varchar2(500),
    procedure_annotations tt_annotations_by_name
  );

  --holds a list of package level annotations indexed (order) by position.
  type tt_object_annotations is table of t_object_annotation index by t_annotation_position;

  --holds all annotations for object
  type t_package_annotations_info is record(
    owner         t_procedure_name,
    name          t_procedure_name,
    annotations   tt_object_annotations
  );

  --list of all package level annotation positions for a given annotaion name
  type tt_package_annot_positions is table of boolean index by t_annotation_position;
  --index used to lookup package level annotations by package-level annotation name
  type tt_annotations_index   is table of tt_package_annot_positions index by t_annotation_name;

  function is_last_annotation_for_proc(a_annotations ut_annotations, a_index binary_integer) return boolean is
  begin
    return a_index = a_annotations.count or a_annotations(a_index).subobject_name != nvl(a_annotations(a_index+1).subobject_name, ' ');
  end;

  function get_procedure_annotations(a_annotations ut_annotations, a_index binary_integer) return tt_annotations_by_name is
    l_result tt_annotations_by_name;
    i        binary_integer := a_index;
  begin
    loop
      l_result(a_annotations(i).name)(i) := a_annotations(i).text;
      exit when is_last_annotation_for_proc(a_annotations, i);
      i := a_annotations.next(i);
    end loop;
    return l_result;
  end;

  function convert_object_annotations(a_object ut_annotated_object) return t_package_annotations_info is
    l_result        t_package_annotations_info;
    l_annotation_no binary_integer;
  begin
    l_result.owner := a_object.object_owner;
    l_result.name  := a_object.object_name;
    l_annotation_no := a_object.annotations.first;
    while l_annotation_no is not null loop
      if a_object.annotations(l_annotation_no).subobject_name is null then
        l_result.annotations(l_annotation_no).name := a_object.annotations(l_annotation_no).name;
        l_result.annotations(l_annotation_no).text := a_object.annotations(l_annotation_no).text;
      else
        l_result.annotations(l_annotation_no).procedure_name        := a_object.annotations(l_annotation_no).subobject_name;
        l_result.annotations(l_annotation_no).procedure_annotations := get_procedure_annotations(a_object.annotations, l_annotation_no);
        if l_result.annotations(l_annotation_no).procedure_annotations.count > 0 then
          l_annotation_no := l_annotation_no + l_result.annotations(l_annotation_no).procedure_annotations.count - 1;
        end if;
      end if;
      l_annotation_no := a_object.annotations.next(l_annotation_no);
    end loop;
    return l_result;
  end;

  function build_annotation_index(a_annotations tt_object_annotations ) return tt_annotations_index is
    l_result tt_annotations_index;
    i binary_integer;
  begin
    i := a_annotations.first;
    while i is not null loop
      if a_annotations(i).name is not null then
        l_result(a_annotations(i).name)(i) := true;
      end if;
      i := a_annotations.next(i);
    end loop;
    return l_result;
  end;

  procedure delete_from_annotation_index(
    a_index in out nocopy tt_annotations_index,
    a_start_pos t_annotation_position,
    a_end_pos t_annotation_position
  ) is
    i t_annotation_name;
  begin
    i :=  a_index.first;
    while i is not null loop
      a_index(i).delete(a_start_pos, a_end_pos);
      if a_index(i).count = 0 then
        a_index.delete(i);
      end if;
      i := a_index.next(i);
    end loop;
  end;

  function get_rollback_type(a_rollback_type_name varchar2) return ut_utils.t_rollback_type is
    l_rollback_type ut_utils.t_rollback_type;
  begin
    l_rollback_type :=
      case lower(a_rollback_type_name)
        when 'manual' then ut_utils.gc_rollback_manual
        when 'auto' then ut_utils.gc_rollback_auto
        --TODO - if invalid or no rollback type text specified - give a warning
        else ut_utils.gc_rollback_auto
      end;
     return l_rollback_type;
  end;

  function build_exception_numbers_list(a_annotation_text in varchar2) return ut_integer_list is
    l_throws_list           ut_varchar2_list;
    l_exception_number_list ut_integer_list := ut_integer_list();
    l_regexp_for_excep_nums varchar2(30) := '^-?[[:digit:]]{1,5}$';
  begin
    /*the a_expected_error_codes is converted to a ut_varchar2_list after that is trimmed and filtered to left only valid exception numbers*/
    l_throws_list := ut_utils.string_to_table(a_annotation_text, ',', 'Y');
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
    a_executables in out nocopy ut_executables,
    a_procedure_name varchar2,
    a_event_name ut_utils.t_event_name,
    a_suite_item ut_suite_item
  ) is
    begin
      if a_executables is null then
        a_executables := ut_executables();
      end if;
      a_executables.extend;
      a_executables(a_executables.last) := ut_executable(a_suite_item, a_procedure_name, a_event_name);
  end;

  procedure add_to_list(
    a_executables in out nocopy ut_executables,
    a_annotation_texts tt_annotation_texts,
    a_event_name       ut_utils.t_event_name,
    a_suite_item       ut_suite_item
  ) is
    l_annotation_pos   binary_integer;
    begin
      l_annotation_pos := a_annotation_texts.first;
      while l_annotation_pos is not null loop
        add_to_list(a_executables, a_annotation_texts(l_annotation_pos), a_event_name, a_suite_item );
        l_annotation_pos := a_annotation_texts.next( l_annotation_pos);
      end loop;
    end;

  procedure warning_on_extra_annotations(
    a_suite in out nocopy ut_suite_item,
    a_procedure_info t_object_annotation,
    a_for_annotation varchar2
  ) is
    l_annotation_name t_annotation_name;
    l_warning         varchar2(32767);
  begin
    l_annotation_name := a_procedure_info.procedure_annotations.first;
    while l_annotation_name is not null loop
      l_annotation_name := a_procedure_info.procedure_annotations.next(l_annotation_name);
      if l_annotation_name != a_for_annotation then
        l_warning := l_warning ||'"--%'|| l_annotation_name || '", ';
      end if;
    end loop;
    if l_warning is not null then
      a_suite.put_warning(
          'Annotations: '||rtrim(l_warning,', ')||' were ignored for procedure "'||a_procedure_info.procedure_name||'".' ||
          ' Those annotations cannot be used with annotation:"'||a_for_annotation||'"');
    end if;
  end;

  procedure add_test(
    a_suite in out nocopy ut_suite,
    a_procedure_name varchar2,
    a_annotations    tt_annotations_by_name
  ) is
    l_test             ut_test;
    l_annotation_texts tt_annotation_texts;
    l_annotation_pos   binary_integer;
  begin
    l_test := ut_test(a_suite.object_owner, a_suite.object_name, a_procedure_name);

    if a_annotations.exists('displayname') then
      l_annotation_texts := a_annotations('displayname');
      --take the last definition if more than one was provided
      l_test.description := l_annotation_texts(l_annotation_texts.last);
      --TODO if more than one - warning
    end if;
    l_test.description := coalesce(l_test.description,a_annotations('test')(a_annotations('test').last));
    l_test.path := a_suite.path ||'.'||a_procedure_name;

    if a_annotations.exists('rollback') then
      l_annotation_texts := a_annotations('rollback');
      l_test.rollback_type := get_rollback_type(l_annotation_texts(l_annotation_texts.last));
    end if;

    if a_annotations.exists('beforetest') then
      add_to_list( l_test.before_test_list, a_annotations('beforetest'), ut_utils.gc_before_test, l_test );
    end if;
    if a_annotations.exists('aftertest') then
      add_to_list( l_test.after_test_list, a_annotations('aftertest'), ut_utils.gc_after_test, l_test );
    end if;
    if a_annotations.exists('throws') then
      add_to_throws_numbers_list(l_test.expected_error_codes, a_annotations('throws'));
    end if;
    l_test.disabled_flag := ut_utils.boolean_to_int(a_annotations.exists('disabled'));

    a_suite.add_item(l_test);
  end;

  procedure update_before_after_list(
    a_suite in out nocopy ut_logical_suite,
    a_before_each_list ut_executables,
    a_after_each_list ut_executables
  ) is
    l_test ut_test;
  begin
    if a_suite.items is not null then
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of (ut_test) then
          l_test := treat( a_suite.items(i) as ut_test);
          l_test.before_each_list := a_before_each_list;
          l_test.after_each_list := a_after_each_list;
          a_suite.items(i) := l_test;
        end if;
      end loop;
    end if;
  end;

  procedure add_procedures_from_annot(
    l_annotations tt_object_annotations,
    l_suite in out nocopy ut_suite,
    l_before_each_list out ut_executables,
    l_after_each_list out ut_executables
  ) is
    l_position t_annotation_position;
  begin
    l_before_each_list := ut_executables();
    l_after_each_list := ut_executables();
    l_position := l_annotations.first;
    while l_position is not null loop
      if l_annotations(l_position).procedure_name is not null then
        if l_annotations(l_position).procedure_annotations.exists('beforeeach') then
          add_to_list( l_before_each_list, l_annotations(l_position).procedure_name, ut_utils.gc_before_each, l_suite );
          warning_on_extra_annotations(l_suite, l_annotations(l_position), 'beforeeach');
        elsif l_annotations(l_position).procedure_annotations.exists('aftereach') then
          add_to_list( l_after_each_list, l_annotations(l_position).procedure_name, ut_utils.gc_after_each, l_suite );
          warning_on_extra_annotations(l_suite, l_annotations(l_position), 'aftereach');
        elsif l_annotations(l_position).procedure_annotations.exists('beforeall') then
          add_to_list( l_suite.before_all_list, l_annotations(l_position).procedure_name, ut_utils.gc_before_all, l_suite );
          warning_on_extra_annotations(l_suite, l_annotations(l_position), 'beforeall');
        elsif l_annotations(l_position).procedure_annotations.exists('afterall') then
          add_to_list( l_suite.after_all_list, l_annotations(l_position).procedure_name, ut_utils.gc_after_all, l_suite );
          warning_on_extra_annotations(l_suite, l_annotations(l_position), 'afterall');
        elsif l_annotations(l_position).procedure_annotations.exists('test') then
          add_test( l_suite, l_annotations(l_position).procedure_name, l_annotations(l_position).procedure_annotations);
        end if;
      end if;
      l_position := l_annotations.next(l_position);
    end loop;
  end;

  procedure add_suite_context(
    a_suite              in out nocopy ut_suite,
    a_package_ann_index  in out nocopy tt_annotations_index,
    a_annotations        in out nocopy tt_object_annotations
  ) is
  begin
    null;
--     while l_package_ann_index.exists('context') loop
--       if l_package_ann_index.exists('endcontext')
--          and l_package_ann_index.exists('endcontext').first > l_package_ann_index.exists('context').first then
--         null;
--       end if;
--     end loop;
  end;

  function create_suite(a_package t_package_annotations_info) return ut_logical_suite is
    l_package_ann_index  tt_annotations_index;
    l_annotations        tt_object_annotations;
    l_suite              ut_suite;
    l_before_each_list   ut_executables;
    l_after_each_list    ut_executables;
    l_rollback_type      ut_utils.t_rollback_type;
    l_annotation_text    varchar2(32767);
  begin
    l_annotations         := a_package.annotations;
    l_package_ann_index   := build_annotation_index(l_annotations);
    if l_package_ann_index.exists('suite') then
      --create an incomplete suite
      l_suite := ut_suite(a_package.owner, a_package.name);

      l_suite.description := l_annotations(l_package_ann_index('suite').first).text;
      --TODO - check that there is only one `suite` annotation defined - if not -> warning
      --if l_package_ann_index('suite').count > 1 then ... end if;

      if l_package_ann_index.exists('context') then
        if l_package_ann_index.exists('endcontext') then
--           add_suite_context(
--               l_suite,
--               l_package_ann_index('context').first,
--               l_package_ann_index('endcontext').first
--           );
          l_annotations.delete(l_package_ann_index('context').first, l_package_ann_index('endcontext').first);
          delete_from_annotation_index(l_package_ann_index, l_package_ann_index('context').first, l_package_ann_index('endcontext').first);
        -- else TODO - add warning about context without endcontext
        end if;
      end if;

      if l_package_ann_index.exists('suitepath') then
        --TODO - check that there is only one `suitepath` annotation defined - if not -> warning
        --TODO - check that the `suitepath` annotation has text in it - if not -> warning
        --TODO - check that text of `suitepath` annotation is of valid format - if not -> warning
        l_annotation_text := l_annotations(l_package_ann_index('suitepath').first).text;
        if l_annotation_text is not null then
          l_suite.path := trim(l_annotations(l_package_ann_index('suitepath').first).text)||'.'||a_package.name;
        end if;
      end if;
      l_suite.path := lower(coalesce(l_suite.path, a_package.name));

      if l_package_ann_index.exists('displayname') then
        --TODO - check that there is only one `displayname` annotation defined - if not -> warning
        l_suite.description  := l_annotations(l_package_ann_index('displayname').first).text;
      end if;

      if l_package_ann_index.exists('rollback') then
        l_rollback_type := get_rollback_type(l_annotations(l_package_ann_index('rollback').first).text);
      end if;

      l_suite.disabled_flag := ut_utils.boolean_to_int(l_package_ann_index.exists('disabled'));

      --process procedure annotations for suite
      add_procedures_from_annot(l_annotations, l_suite, l_before_each_list, l_after_each_list);

      l_suite.set_default_rollback_type(coalesce(l_rollback_type, ut_utils.gc_rollback_auto));
    end if;

    update_before_after_list(l_suite, l_before_each_list, l_after_each_list);

    return l_suite;
  end;

  function create_suite(a_object ut_annotated_object) return ut_logical_suite is
  begin
    return create_suite(convert_object_annotations(a_object));
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
