create or replace package body ut_coverage is

  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer is
    l_run_number  binary_integer;
  begin
    execute immediate 'truncate table plsql_profiler_units';
    execute immediate 'truncate table plsql_profiler_data';
    execute immediate 'truncate table plsql_profiler_runs';
    dbms_profiler.start_profiler(run_comment => a_run_comment, run_number => l_run_number);
    return l_run_number;
  end;

  procedure profiler_flush is
    l_return_code binary_integer;
    l_run_number  binary_integer;
  begin
    l_return_code := dbms_profiler.flush_data();
  end;

  procedure profiler_pause is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.pause_profiler();
  end;

  procedure profiler_resume is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.resume_profiler();
  end;

  procedure profiler_stop is
    l_return_code binary_integer;
  begin
    l_return_code := dbms_profiler.stop_profiler();
  end;

  function get_coverage_data(a_run_id integer) return tt_coverage is
    type t_coverage_row is record(
    unit_owner    varchar2(250),
    unit_name     varchar2(250),
    line_number   integer,
    total_occur   number(38,0)
    );
    type tt_coverage_rows is table of t_coverage_row;
    l_data   tt_coverage_rows;
    l_result tt_coverage;
  begin
    -- TODO - add inclusive and exclusive filtering
    select u.unit_owner, u.unit_name, d.line# as line_number, d.total_occur
      bulk collect into l_data
      from plsql_profiler_units u, plsql_profiler_data d
     where u.runid = d.runid
--       and u.runid = a_run_id
       and u.unit_number = d.unit_number
       and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
       and d.total_occur is not null
     order by u.unit_owner, u.unit_name, d.line#;

    for i in 1 .. l_data.count loop
      l_result(l_data(i).unit_owner)(l_data(i).unit_name)(l_data(i).line_number) := ( l_data(i).total_occur > 0 );
    end loop;
    return l_result;
  end;

end;
/
