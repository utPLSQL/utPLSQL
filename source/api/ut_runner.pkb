create or replace package body ut_runner is

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



  /**
   * Public functions
   */
  function version return varchar2 is
  begin
    return ut_utils.gc_version;
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporters ut_reporters, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
    l_items_to_run  ut_run;
    l_listener      ut_event_listener;
  begin
    begin
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

      ut_utils.cleanup_temp_tables;
    exception
      when others then
        ut_utils.cleanup_temp_tables;
        l_listener.fire_on_event(ut_utils.gc_finalize);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        dbms_output.put_line(dbms_utility.format_error_stack);
        raise;
    end;
    if a_fail_on_errors and l_items_to_run.result in (ut_utils.tr_failure, ut_utils.tr_error) then
      raise_application_error(ut_utils.gc_some_tests_failed, 'Some tests failed');
    end if;
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporters ut_reporters, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      a_paths, a_reporters, a_color_console, a_coverage_schemes,
      ut_file_mapper.build_file_mappings(a_source_files),
      ut_file_mapper.build_file_mappings(a_test_files),
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      a_paths, ut_reporters(coalesce(a_reporter,ut_documentation_reporter())),
      a_color_console, a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end;

  procedure run(
    a_paths ut_varchar2_list, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      a_paths, ut_reporters(coalesce(a_reporter,ut_documentation_reporter())),
      a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end;


  procedure run(
    a_path in varchar2, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))),
      a_reporter, a_color_console, a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end run;

  procedure run(
    a_path in varchar2, a_reporter ut_reporter_base := null, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))),
      a_reporter, a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end run;

  procedure run(
    a_path in varchar2, a_reporters in ut_reporters, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_file_mappings ut_file_mappings := null, a_test_file_mappings ut_file_mappings := null,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))),
      a_reporters, a_color_console, a_coverage_schemes, a_source_file_mappings, a_test_file_mappings,
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end run;

  procedure run(
    a_path in varchar2, a_reporters in ut_reporters, a_color_console boolean := false,
    a_coverage_schemes ut_varchar2_list := null, a_source_files ut_varchar2_list, a_test_files ut_varchar2_list,
    a_include_objects ut_varchar2_list := null, a_exclude_objects ut_varchar2_list := null, a_fail_on_errors boolean default false
  ) is
  begin
    run(
      ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))),
      a_reporters, a_color_console, a_coverage_schemes, a_source_files, a_test_files,
      a_include_objects, a_exclude_objects, a_fail_on_errors
    );
  end run;

end ut_runner;
/
