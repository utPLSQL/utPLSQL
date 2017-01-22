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

  function get_line_status(a_executions binary_integer) return varchar2 is
  begin
    return
      case
        when a_executions > 0 then gc_covered
        when a_executions = 0 then gc_missed
        else gc_skipped
      end;
  end;

  function get_coverage_data(a_run_id integer) return t_coverage is
    type t_coverage_row is record(
    unit_owner    varchar2(250),
    unit_name     varchar2(250),
    line_number   integer,
    total_occur   number(38,0)
    );
    type tt_coverage_rows is table of t_coverage_row;
    l_data   tt_coverage_rows;

    l_result     t_coverage;
    l_line       t_line_info;
    l_new_unit   t_unit_coverage;
    l_new_schema t_schema_coverage;
    begin
    -- TODO - add inclusive and exclusive filtering
    select u.unit_owner, u.unit_name, s.line as line_number,
           --filtering out false - negatives reported by profiler (zero executions while it should be ignored).
           case when
              regexp_instr(
                s.text,
                '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)', 1, 1, 0, 'i'
              ) = 0 then d.total_occur
           end
      bulk collect into l_data
      from plsql_profiler_units u
      join all_source s
        on s.owner = u.unit_owner
       and s.name  = u.unit_name
       and s.type  = rtrim(u.unit_type,' SPEC')
      left join plsql_profiler_data d
        on u.runid = d.runid
       and u.unit_number = d.unit_number
       and d.line# = s.line
     where 1 = 1
--       and u.runid = a_run_id
       and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
     order by u.unit_owner, u.unit_name, d.line#;

    for i in 1 .. l_data.count loop
      l_line.executions := l_data(i).total_occur;
      l_line.status := get_line_status(l_data(i).total_occur);
      l_line.covered := (l_data(i).total_occur > 0);

      if not l_result.schemes.exists(l_data(i).unit_owner) then
        l_result.schemes(l_data(i).unit_owner) := l_new_schema;
      end if;
      if not l_result.schemes(l_data(i).unit_owner).units.exists(l_data(i).unit_name) then
        l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name) := l_new_unit;
        l_result.objects := l_result.objects + 1;
      end if;
      if l_line.covered then
        l_result.covered_lines := l_result.covered_lines + 1;
        l_result.schemes(l_data(i).unit_owner).covered_lines := l_result.schemes(l_data(i).unit_owner).covered_lines + 1;
        l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).covered_lines := l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).covered_lines + 1;
        l_result.executions := l_result.executions + l_line.executions;
        l_result.schemes(l_data(i).unit_owner).executions := l_result.schemes(l_data(i).unit_owner).executions + l_line.executions;
        l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).executions := l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).executions + l_line.executions;
      elsif not l_line.covered then
        l_result.uncovered_lines := l_result.uncovered_lines + 1;
        l_result.schemes(l_data(i).unit_owner).uncovered_lines := l_result.schemes(l_data(i).unit_owner).uncovered_lines + 1;
        l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).uncovered_lines := l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).uncovered_lines + 1;
      end if;
      l_result.total_lines := l_result.total_lines + 1;
      l_result.schemes(l_data(i).unit_owner).total_lines := l_result.schemes(l_data(i).unit_owner).total_lines + 1;
      l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).total_lines := l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).total_lines + 1;
      l_result.schemes(l_data(i).unit_owner).units(l_data(i).unit_name).lines(l_data(i).line_number) := l_line;
    end loop;
    return l_result;
  end;

end;
/
