create or replace package body ut_coverage_helper is

  g_coverage_id integer;
  g_develop_mode boolean := false;

  function get_coverage_id return integer is
  begin
    return g_coverage_id;
  end;

  function  is_develop_mode return boolean is
  begin
    return g_develop_mode;
  end;

  function coverage_start(a_run_comment varchar2) return integer is
  begin
    dbms_profiler.start_profiler(run_comment => a_run_comment, run_number => g_coverage_id);
    coverage_pause();
    return g_coverage_id;
  end;

  procedure coverage_start(a_run_comment varchar2) is
    l_run_number  binary_integer;
  begin
    l_run_number := coverage_start(a_run_comment);
  end;

  procedure coverage_start_develop is
  begin
    g_develop_mode := true;
    coverage_start('utPLSQL Code coverage run in development MODE '||ut_utils.to_string(systimestamp));
  end;

  procedure coverage_flush is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.flush_data();
  end;

  procedure coverage_pause is
    l_return_code binary_integer;
  begin
    if not g_develop_mode then
      l_return_code := dbms_profiler.pause_profiler();
    end if;
  end;

  procedure coverage_resume is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.resume_profiler();
  end;

  procedure coverage_stop is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.stop_profiler();
  end;

  function get_raw_coverage_data return ut_coverage_rows pipelined is

    l_results           ut_coverage_rows;

    cursor l_coverage_data(a_coverage_id integer) is
      select ut_coverage_row(
                lower(u.unit_owner||'.'||u.unit_name),
                u.unit_owner, u.unit_name, u.unit_type,
                d.line#, d.total_occur)
        from plsql_profiler_units u
        join plsql_profiler_data d
          on u.runid = d.runid
         and u.unit_number = d.unit_number
       where u.runid = g_coverage_id
         --exclude specification
         and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC', 'ANONYMOUS BLOCK');
  begin
    open l_coverage_data( get_coverage_id());
    loop
      fetch l_coverage_data bulk collect into l_results limit 1000;
      for i in 1 .. l_results.count loop
        pipe row (l_results(i));
      end loop;

      exit when l_coverage_data%notfound;
    end loop;
    close l_coverage_data;

    return;
  end;

end;
/
