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

  function version return varchar2 is
  begin
    return ut_utils.gc_version;
  end;

  procedure run(a_paths ut_varchar2_list, a_reporters ut_reporters, a_color_console boolean := false) is
    l_items_to_run  ut_run;
    l_listener      ut_event_listener;
    l_current_suite ut_logical_suite;
  begin
    ut_output_buffer.cleanup_buffer();

    ut_console_reporter_base.set_color_enabled(a_color_console);
    if a_reporters is null or a_reporters.count = 0 then
      l_listener := ut_event_listener(ut_reporters(ut_documentation_reporter()));
    else
      l_listener := ut_event_listener(a_reporters);
    end if;
    l_items_to_run := ut_run( ut_suite_manager.configure_execution_by_path(a_paths), a_paths );
    l_items_to_run.do_execute(l_listener);

    ut_output_buffer.close(l_listener.reporters);
  exception
    when others then
      ut_output_buffer.close(l_listener.reporters);
      dbms_output.put_line(dbms_utility.format_error_backtrace);
      dbms_output.put_line(dbms_utility.format_error_stack);
      raise;
  end;

  procedure run(a_paths ut_varchar2_list, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false) is
  begin
    run(a_paths, ut_reporters(coalesce(a_reporter,ut_documentation_reporter())), a_color_console);
  end;


  procedure run(a_path in varchar2, a_reporter ut_reporter_base := ut_documentation_reporter(), a_color_console boolean := false) is
  begin
    run(ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))), a_reporter, a_color_console);
  end run;

  procedure run(a_path in varchar2, a_reporters in ut_reporters, a_color_console boolean := false) is
  begin
    run(ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))), a_reporters, a_color_console);
  end run;

end ut_runner;
/
