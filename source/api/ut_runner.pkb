create or replace package body ut_runner is

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

  /**
   * Private functions
   */
  function to_ut_object_list(a_names ut_varchar2_list) return ut_object_names is
    l_result ut_object_names;
  begin
    if a_names is not null then
      l_result := ut_object_names();
      for i in 1 .. a_names.count loop
        l_result.extend;
        l_result(l_result.last) := ut_object_name(a_names(i));
      end loop;
    end if;
    return l_result;
  end;

  procedure finish_run(a_reporters ut_reporters) is
  begin
    ut_utils.cleanup_temp_tables;
    ut_output_buffer.close(a_reporters);
    ut_metadata.reset_source_definition_cache;
    ut_utils.read_cache_to_dbms_output();
    ut_coverage_helper.cleanup_tmp_table();
  end;


  /**
   * Public functions
   */
  function version return varchar2 is
  begin
    return ut_utils.gc_version;
  end;

  function version_compatibility_check( a_requested varchar2, a_current varchar2 := null ) return integer is
    l_result boolean := false;
    l_requested ut_utils.t_version := ut_utils.to_version(a_requested);
    l_current ut_utils.t_version := ut_utils.to_version(coalesce(a_current,version()));
  begin
    if l_requested.major = l_current.major
       and (l_requested.minor < l_current.minor or l_requested.minor is null
            or l_requested.minor = l_current.minor and (l_requested.bugfix <= l_current.bugfix or l_requested.bugfix is null)) then
      l_result := true;
    end if;
    return ut_utils.boolean_to_int(l_result);
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporters ut_reporters, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
    l_items_to_run ut_run;
    l_listener     ut_event_listener;
  begin
    begin
      ut_output_buffer.cleanup_buffer();
      ut_utils.save_dbms_output_to_cache();

      ut_console_reporter_base.set_color_enabled(a_color_console);
      if a_reporters is null or a_reporters.count = 0 then
        l_listener := ut_event_listener(ut_reporters(ut_documentation_reporter()));
      else
        l_listener := ut_event_listener(a_reporters);
      end if;
      l_items_to_run := ut_run(
        ut_suite_manager.configure_execution_by_path(a_paths),
        a_paths,
        ut_utils.convert_collection(a_coverage_schemes),
        to_ut_object_list(a_exclude_objects),
        to_ut_object_list(a_include_objects),
        set(a_source_file_mappings),
        set(a_test_file_mappings)
      );
      l_items_to_run.do_execute(l_listener);

      finish_run(l_listener.reporters);
    exception
      when others then
        finish_run(l_listener.reporters);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        dbms_output.put_line(dbms_utility.format_error_stack);
        raise;
    end;
    if a_fail_on_errors and l_items_to_run.result in (ut_utils.tr_failure, ut_utils.tr_error) then
      raise_application_error(ut_utils.gc_some_tests_failed, 'Some tests failed');
    end if;
  end;

  procedure rebuild_annotation_cache(a_object_owner varchar2, a_object_type varchar2 := null) is
  begin
    ut_annotation_manager.rebuild_annotation_cache(a_object_owner, coalesce(a_object_type,'PACKAGE'));
  end;

  procedure purge_cache(a_object_owner varchar2, a_object_type varchar2 := null) is
  begin
    ut_annotation_manager.purge_cache(a_object_owner, coalesce(a_object_type,'PACKAGE'));
  end;

  function get_unit_tests_info(a_owner varchar2, a_package_name varchar2 := null) return sys_refcursor is
    l_result   sys_refcursor;
    l_filter   varchar2(100);
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
  begin
    l_filter := case when a_package_name is null then 'is null' else '= o.object_name' end;
    open l_result for
      'select o.object_owner owner, o.object_name as package_name, upper(a.subobject_name) as procedure_name,' ||
      '       a.name annotation, a.text annotation_text' ||
      '  from table('||l_ut_owner||'.ut_annotation_manager.get_annotated_objects(:a_owner, ''PACKAGE'')) o,' ||
      '       table(o.annotations) a' ||
      ' where exists (select 1 from table(o.annotations) s where s.name=''suite'') ' ||
      '  and :a_package_name ' || l_filter
    using a_owner, a_package_name;
    return l_result;
  end;

end ut_runner;
/
