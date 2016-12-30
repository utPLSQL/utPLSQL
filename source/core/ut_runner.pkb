create or replace package body ut_runner is

  g_run_params  t_run_params;

  procedure run(a_paths in ut_varchar2_list, a_reporter in ut_reporter) is
    l_objects_to_run  ut_objects_list;
    l_reporter        ut_reporter := a_reporter;
    ut_running_suite ut_test_suite;
  begin
    ut_suite_manager.configure_execution_by_path(a_paths,l_objects_to_run);

    if l_objects_to_run.count > 0 then
      l_reporter.before_run(a_suites => l_objects_to_run);
      for i in 1 .. l_objects_to_run.count loop

        ut_running_suite := treat(l_objects_to_run(i) as ut_test_suite);
        ut_running_suite.do_execute(l_reporter);
        l_objects_to_run(i) := ut_running_suite;

      end loop;
      l_reporter.after_run(a_suites => l_objects_to_run);
    end if;
  end;


  procedure run(a_path in varchar2, a_reporter in ut_reporter) is
  begin
    run(ut_varchar2_list(coalesce(a_path, sys_context('userenv', 'current_schema'))), a_reporter);
  end run;

  procedure set_run_params(a_params ut_varchar2_list) is
    l_call_param          t_call_param;
    l_call_params         tt_call_params := tt_call_params();
    l_ut_paths            varchar2(4000);
    l_force_out_to_screen boolean;
  begin
    for param in
      ( with
          param_vals as(
            select regexp_substr(column_value,'-([fos])\=?(.*)',1,1,'c',1) param_type,
            regexp_substr(column_value,'-([fos])\=(.*)',1,1,'c',2) param_value
            from table(a_params)
            where column_value is not null)
        select param_type, param_value
        from param_vals
        where param_type is not null)
    loop
      if param.param_type = 'f' then
        l_call_params.extend;
        l_call_params(l_call_params.last) := l_call_param;
        l_call_params(l_call_params.last).ut_reporter_name := param.param_value;
        l_force_out_to_screen := false;
      elsif l_call_params.last is not null then
        if param.param_type = 'o' then
          l_call_params(l_call_params.last).output_file_name := param.param_value;
          if not l_force_out_to_screen then
            l_call_params(l_call_params.last).output_to_screen := 'off';
          end if;
        elsif param.param_type = 's' then
          l_call_params(l_call_params.last).output_to_screen := 'on';
          l_force_out_to_screen := true;
        end if;
      end if;
    end loop;

    begin
      select ''''||replace(ut_paths,',',''',''')||''''
        into g_run_params.ut_paths
        from (select regexp_substr(column_value,'-p\=(.*)',1,1,'c',1) as ut_paths from table(a_params) )
       where ut_paths is not null;
    exception
      when no_data_found then
        g_run_params.ut_paths := 'user';
      when too_many_rows then
        raise_application_error(-20000, 'Parameter "-p=ut_paths" defined more than once. Only one "-p=ut_paths" parameter can be used.');
    end;
    for i in 1 .. cardinality(l_call_params) loop
      execute immediate 'begin :l_output_id := '||get_streamed_output_type_name()||'().generate_output_id(); end;'
      using out l_call_params(i).output_id;
    end loop;
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
