create or replace package body ut_runner is

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
    l_items_to_run := ut_run( ut_suite_manager.configure_execution_by_path(a_paths) );
    l_items_to_run.do_execute(l_listener);
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

  procedure set_run_params(a_params ut_varchar2_list) is
  begin
    ut_runner_helper.set_run_params(a_params);
  end set_run_params;

  function get_run_params return t_run_params is
  begin
    return ut_runner_helper.get_run_params();
  end;

  function get_streamed_output_type_name return varchar2 is
  begin
    return ut_runner_helper.get_streamed_output_type_name();
  end;

end ut_runner;
/
