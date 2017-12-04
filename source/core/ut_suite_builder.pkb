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

  ------------------

  function create_suite(a_object ut_annotated_object) return ut_logical_suite is
    l_is_suite              boolean := false;
    l_is_test               boolean := false;
    l_suite_disabled        boolean := false;
    l_test_disabled         boolean := false;
    l_suite_items           ut_suite_items := ut_suite_items();
    l_suite_name            varchar2(4000);

    l_default_setup_proc    varchar2(250 char);
    l_default_teardown_proc varchar2(250 char);
    l_suite_setup_proc      varchar2(250 char);
    l_suite_teardown_proc   varchar2(250 char);
    l_suite_path            varchar2(4000 char);

    l_proc_name             varchar2(250 char);

    l_suite                 ut_logical_suite;
    l_test                  ut_test;

    l_suite_rollback        integer;

    l_beforetest_procedure  varchar2(250 char);
    l_aftertest_procedure   varchar2(250 char);
    l_rollback_type         integer;
    l_displayname           varchar2(4000);

  begin
    l_suite_rollback := ut_utils.gc_rollback_auto;
    for i in 1 .. a_object.annotations.count loop

      if a_object.annotations(i).subobject_name is null then

        if a_object.annotations(i).name in ('suite','displayname') then
          l_suite_name := a_object.annotations(i).text;
          if a_object.annotations(i).name = 'suite' then
            l_is_suite := true;
          end if;
        elsif a_object.annotations(i).name = 'disabled' then
          l_suite_disabled := true;
        elsif a_object.annotations(i).name = 'suitepath' and  a_object.annotations(i).text is not null then
          l_suite_path := a_object.annotations(i).text || '.' || lower(a_object.object_name);
        elsif a_object.annotations(i).name = 'rollback' then
          if lower(a_object.annotations(i).text) = 'manual' then
            l_suite_rollback := ut_utils.gc_rollback_manual;
          else
            l_suite_rollback := ut_utils.gc_rollback_auto;
          end if;
        end if;

      elsif l_is_suite then

        l_proc_name := a_object.annotations(i).subobject_name;

        if a_object.annotations(i).name = 'beforeeach' and l_default_setup_proc is null then
          l_default_setup_proc := l_proc_name;
        elsif a_object.annotations(i).name = 'aftereach' and l_default_teardown_proc is null then
          l_default_teardown_proc := l_proc_name;
        elsif a_object.annotations(i).name = 'beforeall' and l_suite_setup_proc is null then
          l_suite_setup_proc := l_proc_name;
        elsif a_object.annotations(i).name = 'afterall' and l_suite_teardown_proc is null then
          l_suite_teardown_proc := l_proc_name;


        elsif a_object.annotations(i).name = 'disabled' then
          l_test_disabled := true;
        elsif a_object.annotations(i).name = 'beforetest' then
          l_beforetest_procedure := a_object.annotations(i).text;
        elsif a_object.annotations(i).name = 'aftertest' then
          l_aftertest_procedure := a_object.annotations(i).text;
        elsif a_object.annotations(i).name in ('displayname','test') then
          l_displayname := a_object.annotations(i).text;
          if a_object.annotations(i).name = 'test' then
            l_is_test := true;
          end if;
        elsif a_object.annotations(i).name = 'rollback' then
          if lower(a_object.annotations(i).text) = 'manual' then
            l_rollback_type := ut_utils.gc_rollback_manual;
          elsif lower(a_object.annotations(i).text) = 'auto' then
            l_rollback_type := ut_utils.gc_rollback_auto;
          end if;
        end if;

        if l_is_test
           and (i = a_object.annotations.count
                or l_proc_name != nvl(a_object.annotations(i+1).subobject_name, ' ') ) then
          l_suite_items.extend;
          l_suite_items(l_suite_items.last) :=
            ut_test(a_object_owner          => a_object.object_owner
                   ,a_object_name           => a_object.object_name
                   ,a_name                  => l_proc_name
                   ,a_description           => l_displayname
                   ,a_rollback_type         => coalesce(l_rollback_type, l_suite_rollback)
                   ,a_disabled_flag         => l_suite_disabled or l_test_disabled
                   ,a_before_test_proc_name => l_beforetest_procedure
                   ,a_after_test_proc_name  => l_aftertest_procedure);

          l_is_test := false;
          l_test_disabled := false;
          l_aftertest_procedure  := null;
          l_beforetest_procedure := null;
          l_rollback_type        := null;
        end if;

      end if;
    end loop;

    if l_is_suite then
      l_suite := ut_suite (
          a_object_owner          => a_object.object_owner,
          a_object_name           => a_object.object_name,
          a_name                  => a_object.object_name, --this could be different for sub-suite (context)
          a_path                  => l_suite_path,  --a patch for this suite (excluding the package name of current suite)
          a_description           => l_suite_name,
          a_rollback_type         => l_suite_rollback,
          a_disabled_flag         => l_suite_disabled,
          a_before_all_proc_name  => l_suite_setup_proc,
          a_after_all_proc_name   => l_suite_teardown_proc
      );
      for i in 1 .. l_suite_items.count loop
        l_test := treat(l_suite_items(i) as ut_test);
        l_test.set_beforeeach(l_default_setup_proc);
        l_test.set_aftereach(l_default_teardown_proc);
        l_test.path := l_suite.path  || '.' ||  l_test.name;
        l_suite.add_item(l_test);
      end loop;
    end if;

    return l_suite;

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
