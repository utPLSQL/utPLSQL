create or replace package body ut_coverage is

  g_skipped_objects ut_object_names;

  function get_coverage_id return integer is
  begin
    return ut_coverage_helper.get_coverage_id;
  end;

  function coverage_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer is
  begin
    return ut_coverage_helper.coverage_start(a_run_comment);
  end;

  procedure coverage_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) is
  begin
    ut_coverage_helper.coverage_start(a_run_comment);
  end;

  procedure coverage_start_develop(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) is
  begin
    ut_coverage_helper.coverage_start_develop(a_run_comment);
  end;

  procedure coverage_flush is
  begin
    ut_coverage_helper.coverage_flush();
  end;

  procedure coverage_pause is
  begin
    ut_coverage_helper.coverage_pause();
  end;

  procedure coverage_resume is
  begin
    ut_coverage_helper.coverage_resume();
  end;

  procedure coverage_stop is
  begin
    ut_coverage_helper.coverage_resume();
  end;

  procedure skip_coverage_for(a_object ut_object_name) is
  begin
    if g_skipped_objects is null then
      g_skipped_objects := ut_object_names();
    end if;
      g_skipped_objects.extend;
      g_skipped_objects(g_skipped_objects.last) := a_object;
  end;

  function get_coverage_data(a_coverage_id integer := null) return t_coverage is

    type t_coverage_row is record(
      name          varchar2(500),
      line_number   integer,
      total_occur   number(38,0)
    );
    type tt_coverage_rows is table of t_coverage_row;

    l_data             ut_coverage_rows;
    l_result           t_coverage;
    l_new_unit         t_unit_coverage;
    l_skipped_objects  ut_object_names := ut_object_names();
  begin

    if not ut_coverage_helper.is_develop_mode() then
      l_skipped_objects := ut_utils.get_utplsql_objects_list() multiset union g_skipped_objects;
    end if;

    -- TODO - add inclusive and exclusive filtering
    select ut3.ut_coverage_row(
             lower(s.owner||'.'||s.name),
             s.owner, s.name, s.type, s.line,
           --filtering out false - negatives reported by profiler (zero executions while it should be ignored).
           case when
              regexp_instr(
                s.text,
                '^\s*(((not)?\s*(overriding|final|instantiable)\s*)*(constructor|member)?\s*(procedure|function)|begin|end\s*;)', 1, 1, 0, 'i'
              ) = 0 then u.total_occur
           end
          )
      bulk collect into l_data
      from all_source s
      --need to use owner privileges here
      left join table( ut3.ut_coverage_helper.get_raw_coverage_data() ) u
        on s.owner = u.owner
       and s.name  = u.name
       and s.type  = u.type
       and s.line  = nvl(u.line_number, s.line)
     where s.type not in ('PACKAGE', 'TYPE')
       and s.owner = 'UT3'
       --Exclude calls to utPLSQL framework and Unit Test packages
       and not exists(select 1 from table(l_skipped_objects) l where s.name = l.name and s.owner = l.owner)
     order by s.owner, s.name, s.line;

    for i in 1 .. l_data.count loop

      if not l_result.objects.exists(l_data(i).full_name) then
        l_result.objects(l_data(i).full_name) := l_new_unit;
      end if;
      if l_data(i).total_occur > 0 then
        l_result.covered_lines := l_result.covered_lines + 1;
        l_result.executions := l_result.executions + l_data(i).total_occur;
        l_result.objects(l_data(i).full_name).covered_lines := l_result.objects(l_data(i).full_name).covered_lines + 1;
        l_result.objects(l_data(i).full_name).executions := l_result.objects(l_data(i).full_name).executions + l_data(i).total_occur;
      elsif l_data(i).total_occur = 0 then
        l_result.uncovered_lines := l_result.uncovered_lines + 1;
        l_result.objects(l_data(i).full_name).uncovered_lines := l_result.objects(l_data(i).full_name).uncovered_lines + 1;
      end if;
      l_result.total_lines := l_result.total_lines + 1;
      l_result.objects(l_data(i).full_name).total_lines := l_result.objects(l_data(i).full_name).total_lines + 1;
      l_result.objects(l_data(i).full_name).lines(l_data(i).line_number) := l_data(i).total_occur;
    end loop;
    return l_result;
  end;

end;
/
