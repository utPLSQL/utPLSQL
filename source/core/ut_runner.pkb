create or replace package body ut_runner is

  g_run_params  t_run_params;

  procedure run(a_paths ut_varchar2_list, a_reporters ut_reporters) is
    l_items_to_run  ut_run;
    l_listener      ut_event_listener;
    l_current_suite ut_suite;
  begin
    if a_reporters is null or a_reporters.count = 0 then
      l_listener := ut_event_listener(ut_reporters(ut_documentation_reporter()));
    else
      l_listener := ut_event_listener(a_reporters);
    end if;
    l_items_to_run := ut_run( ut_suite_manager.configure_execution_by_path(a_paths) );
    l_items_to_run.do_execute(l_listener);
  end;

  procedure run(a_paths ut_varchar2_list, a_reporter ut_reporter := ut_documentation_reporter()) is
  begin
    run(a_paths, ut_reporters(coalesce(a_reporter,ut_documentation_reporter())));
  end;


  procedure run(a_path in varchar2, a_reporter ut_reporter := ut_documentation_reporter()) is
  begin
    run(ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))), a_reporter);
  end run;

  procedure run(a_path in varchar2, a_reporters in ut_reporters) is
  begin
    run(ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))), a_reporters);
  end run;

  function parse_reporting_params(a_params ut_varchar2_list) return tt_call_params is
    l_default_call_param  t_call_param;
    l_call_params         tt_call_params := tt_call_params();
    l_force_out_to_screen boolean;
  begin
    for param in(
      with
        param_vals as(
          select regexp_substr(column_value,'-([fos])\=?(.*)',1,1,'c',1) param_type,
                 regexp_substr(column_value,'-([fos])\=(.*)',1,1,'c',2) param_value
          from table(a_params)
          where column_value is not null)
      select param_type, param_value
      from param_vals
      where param_type is not null
    ) loop
      if param.param_type = 'f' or l_call_params.last is null then
        l_call_params.extend;
        l_call_params(l_call_params.last) := l_default_call_param;
        if param.param_type = 'f' then
          l_call_params(l_call_params.last).ut_reporter_name := param.param_value;
        end if;
        l_force_out_to_screen := false;
      end if;
      if param.param_type = 'o' then
        l_call_params(l_call_params.last).output_file_name := param.param_value;
        if not l_force_out_to_screen then
          l_call_params(l_call_params.last).output_to_screen := 'off';
        end if;
      elsif param.param_type = 's' then
        l_call_params(l_call_params.last).output_to_screen := 'on';
        l_force_out_to_screen := true;
      end if;
    end loop;
    if l_call_params.count = 0 then
      l_call_params.extend;
      l_call_params(1) := l_default_call_param;
    end if;
    return l_call_params;
  end;

  function parse_paths_param(a_params ut_varchar2_list) return varchar2 is
    l_paths varchar2(4000);
  begin
    begin
      select ''''||replace(ut_paths,',',''',''')||''''
        into l_paths
        from (select regexp_substr(column_value,'-p\=(.*)',1,1,'c',1) as ut_paths from table(a_params) )
       where ut_paths is not null;
    exception
      when no_data_found then
        l_paths := 'user';
      when too_many_rows then
        raise_application_error(-20000, 'Parameter "-p=ut_path(s)" defined more than once. Only one "-p=ut_path(s)" parameter can be used.');
    end;
    return l_paths;
  end;

  procedure setup_reporting_output_ids(a_call_params in out nocopy tt_call_params) is
  begin
    for i in 1 .. cardinality(a_call_params) loop
      execute immediate 'begin :l_output_id := '||get_streamed_output_type_name()||'().generate_output_id(); end;'
      using out a_call_params(i).output_id;
    end loop;
  end;

  procedure set_run_params(a_params ut_varchar2_list) is
    l_call_params         tt_call_params := tt_call_params();
  begin
    l_call_params := parse_reporting_params(a_params);
    g_run_params.ut_paths := parse_paths_param(a_params);
    setup_reporting_output_ids(l_call_params);
    g_run_params.call_params := l_call_params;
  end set_run_params;

  function get_run_params return t_run_params is
  begin
    return g_run_params;
  end;

  function get_streamed_output_type_name return varchar2 is
    l_result varchar2(255);
  begin
    select type_name
    into l_result
    from user_types where supertype_name = 'UT_OUTPUT_STREAM';
    return lower(l_result);
  end;

end ut_runner;
/
