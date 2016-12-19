create or replace package body ut_runner is

  type t_call_param is record (
    ut_reporter_name varchar2(4000),
    output_file_name   varchar2(4000),
    output_to_screen   varchar2(3) := 'off',
    output_id          varchar2(4000)
  );
  type tt_call_params is table of t_call_param;

  g_call_params tt_call_params;

  g_ut_paths    varchar2(4000);

  function get_streamed_output_type return varchar2 is
    l_result varchar2(255);
  begin
    select type_name
    into l_result
    from user_types where supertype_name = 'UT_OUTPUT_STREAM';
    return lower(l_result)||'()';
  end;

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

  function get_optional_params_script(a_params_count integer := 100) return ut_varchar2_list pipelined is
    l_sql_columns varchar2(4000);
    l_params      varchar2(4000);
  begin
    for i in 1 .. a_params_count loop
      pipe row ('column '||i||' new_value '||i);
    end loop;
    for i in 1 .. a_params_count loop
      l_sql_columns := l_sql_columns ||'null as "'||i||'",';
      l_params := l_params || '''&&'||i||''',';
    end loop;
    pipe row ('select '||rtrim(l_sql_columns, ',') ||' from dual where rownum = 0;');
    pipe row ('' );
    pipe row ('exec ut_runner.set_call_params(ut_varchar2_list('||rtrim(l_params, ',')||'));' );
    return;
  end;

  procedure set_call_params(a_params ut_varchar2_list) is
    l_call_param t_call_param;
  begin
    g_call_params := tt_call_params();
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
        g_call_params.extend;
        g_call_params(g_call_params.last) := l_call_param;
        g_call_params(g_call_params.last).ut_reporter_name := param.param_value;
      elsif g_call_params.last is not null then
        if param.param_type = 'o' then
           g_call_params(g_call_params.last).output_file_name := param.param_value;
        elsif param.param_type = 's' then
          g_call_params(g_call_params.last).output_to_screen := 'on';
        end if;
      end if;
    end loop;

    begin
      select ''''||replace(ut_paths,',',''',''')||''''
        into g_ut_paths
        from (select regexp_substr(column_value,'-p\=(.*)',1,1,'c',1) as ut_paths from table(a_params) )
       where ut_paths is not null;
    exception
      when no_data_found then
        g_ut_paths := 'user';
      when too_many_rows then
        raise_application_error(-20000, 'Parameter "-p=ut_paths" defined more than once. Only one "-p=ut_paths" parameter can be used.');
    end;

  end;

  function get_run_in_background_script return ut_varchar2_list pipelined is
    l_output_id          varchar2(128);
    l_output_type        varchar2(256);
  begin

    l_output_type := get_streamed_output_type();
    pipe row(  'set serveroutput on size unlimited format truncated');
    pipe row(  'set pagesize 0');
    pipe row(  'set linesize 4000');
    pipe row(  'spool run_background.log');
    pipe row(  'declare');
    pipe row(  '  v_reporter       ut_reporter;');
    pipe row(  '  v_reporters_list ut_reporters_list := ut_reporters_list();');
    pipe row(  'begin');
    for i in 1 .. cardinality(g_call_params) loop
      execute immediate 'begin :l_output_id := '||l_output_type||'.generate_output_id(); end;'
        using out g_call_params(i).output_id;
      pipe row('  v_reporter := '||g_call_params(i).ut_reporter_name||'('||l_output_type||');');
      pipe row('  v_reporter.output.output_id := '''||g_call_params(i).output_id||''';');
      pipe row('  v_reporters_list.extend; v_reporters_list(v_reporters_list.last) := v_reporter;');
    end loop;
    pipe row(  '  ut.run( ut_varchar2_list('||g_ut_paths||'), ut_composite_reporter( v_reporters_list ) );');
    pipe row(  'end;');
    pipe row(  '/');
    pipe row(  'exit');

    return;
  end;

  function get_outputs_script return ut_varchar2_list pipelined is
  begin
    for i in 1 .. cardinality(g_call_params) loop
      pipe row('set termout '||g_call_params(i).output_to_screen);
      if g_call_params(i).output_file_name is not null then
        pipe row('spool '||g_call_params(i).output_file_name);
        pipe row('select * from table( '||get_streamed_output_type()||'.get_lines('''||g_call_params(i).output_id||''') );');
        pipe row('spool off');
      else
        pipe row('select * from table( '||get_streamed_output_type()||'.get_lines('''||g_call_params(i).output_id||''') );');
      end if;
    end loop;
  end;

end ut_runner;
/
