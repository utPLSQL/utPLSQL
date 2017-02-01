create or replace package body ut_coverage is

  g_skipped_objects ut_object_names;
  g_schema_names ut_varchar2_list;

  function get_coverage_id return integer is
  begin
    return ut_coverage_helper.get_coverage_id;
  end;

  procedure set_schema_names(a_schema_names ut_varchar2_list) is
  begin
    g_skipped_objects := ut_object_names();
    if a_schema_names is not null and a_schema_names.count>0 then
      g_schema_names := a_schema_names;
    else
      g_schema_names := ut_varchar2_list(sys_context('userenv','current_schema'));
    end if;
  end;

  function coverage_start(a_schema_names ut_varchar2_list := ut_varchar2_list(sys_context('userenv','current_schema'))) return integer is
  begin
    set_schema_names(a_schema_names);
    return ut_coverage_helper.coverage_start('utPLSQL Code coverage run '||ut_utils.to_string(systimestamp));
  end;

  procedure coverage_start(a_schema_names ut_varchar2_list := ut_varchar2_list(sys_context('userenv','current_schema'))) is
    l_coverage_id integer;
  begin
    l_coverage_id := coverage_start(a_schema_names);
  end;

  procedure coverage_start_develop is
  begin
    set_schema_names(null);
    ut_coverage_helper.coverage_start_develop();
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
    ut_coverage_helper.coverage_stop();
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
      l_skipped_objects := ut_utils.get_utplsql_objects_list() multiset union set(g_skipped_objects);
    end if;

    -- TODO - add inclusive and exclusive filtering
    select ut_coverage_row(
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
      left join table( ut_coverage_helper.get_raw_coverage_data() ) u
        on s.owner = u.owner
       and s.name  = u.name
       and s.type  = u.type
       and s.line  = nvl(u.line_number, s.line)
     where s.type not in ('PACKAGE', 'TYPE')
       and s.owner in (select t.column_value from table(g_schema_names) t)
       --Exclude calls to utPLSQL framework and Unit Test packages
       and not exists(select 1 from table(l_skipped_objects) l where s.owner = l.owner AND s.name = l.name)
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
