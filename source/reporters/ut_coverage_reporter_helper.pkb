create or replace package body ut_coverage_reporter_helper is

  type t_source_row is record (
    line integer,
    text varchar2(32767)
  );
  type tt_source_data is table of t_source_row;

  --holds information about coverage data for run
  g_coverage           tt_coverage;

  --hold information about run coverage totals
  g_run_total_lines    integer := 0;
  g_run_relevant_lines integer := 0;
  g_run_covered_lines  integer := 0;

  --temporary clob for index file
  g_index_file_lines   clob;

  /**************
  * private definitions
  */
  procedure reset_globals is
  begin
    g_coverage.delete;
    g_run_total_lines    := 0;
    g_run_relevant_lines := 0;
    g_run_covered_lines  := 0;
    dbms_lob.createtemporary(g_index_file_lines, true);
  end;

  function get_file(a_file_name varchar2, a_is_static varchar2) return clob is
    l_content clob;
  begin
    select file_content
      into l_content
      from ut_coverage_templates
     where is_static = a_is_static
       and file_name = a_file_name;
    return l_content;
  end;

  function build_table_line(a_object_owner varchar2, a_object_name varchar2) return varchar2 is
    l_result varchar2(32767);
  begin
--     l_result :=
-- q'-    <tr class="all_schemas all_coverage <%= schema %>_schema <%= ((code_coverage.to_i/10)..(code_coverage==100 ? 10 : 9)).map{|i| (i+1).to_s<<'0'}.join(' ') %>">
--           <td class="left_align"><a href="<%= file_name %>"><%= object_name %></a></td>
--           <td class='right_align'><tt><%= total_lines %></tt></td>
--           <td class='right_align'><tt><%= analyzed_lines %></tt></td>
--           <td class="left_align"><div class="percent_graph_legend"><tt class=''><%= '%.2f' % total_coverage %>%</tt></div>
--         <div class="percent_graph">
--           <div class="covered" style="width:<%= total_coverage.to_i %>px"></div>
--           <div class="uncovered" style="width:<%= 100 - total_coverage.to_i %>px"></div>
--         </div></td>
--           <td class="left_align"><div class="percent_graph_legend"><tt class=''><%= '%.2f' % code_coverage %>%</tt></div>
--         <div class="percent_graph">
--           <div class="covered" style="width:<%= code_coverage.to_i %>px"></div>
--           <div class="uncovered" style="width:<%= 100 - code_coverage.to_i %>px"></div>
--         </div></td>
--         </tr>
-- -';
    return l_result;
  end;

  function build_details_file_content(a_object_full_name varchar2, a_source_code tt_source_data,
    a_coverage_data tt_unit_coverage, a_html_table_line varchar2
  ) return clob is
    l_file_part    varchar2(32767);
    l_details_file clob;
    l_classname    varchar2(30);
  begin
    dbms_lob.createtemporary(l_details_file,true);
    l_file_part :=
'<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
  <title>'||a_object_full_name||' - coverage report</title>
  <link href="coverage.css" media="all" rel="stylesheet" type="text/css">
</head>
<body>
  <h1>'||a_object_full_name||'</h1>
  <div class="report_table_wrapper">
    <table class=''report'' id=''report_table''>
      <thead>
        <tr>
          <th class="left_align">Name</th>
          <th class="left_align">Code Coverage</th>
          <th class="right_align">Total Lines</th>
          <th class="right_align">Relevant Lines</th>
          <th class="right_align">Covered Lines</th>
          <th class="right_align">Uncovered Lines</th>
        </tr>
      </thead>
      <tbody>
        '||a_html_table_line||'
      </tbody>
    </table>
  </div>
  <table class="details">';
    dbms_lob.writeappend(l_details_file, length(l_file_part), l_file_part);

    for i in 1 .. a_source_code.count loop
      if a_coverage_data.exists(a_source_code(i).line) then
        if a_coverage_data(a_source_code(i).line) > 0 then
          l_classname := 'marked';
        else
          l_classname := 'uncovered';
        end if;
      else
        l_classname := 'inferred';
      end if;

      l_file_part := '
      <tr class="'||l_classname||'">
        <td><pre><a name="line'||a_source_code(i).line||'">'||a_source_code(i).line||' </a>'||dbms_xmlgen.convert(a_source_code(i).text)||'</pre></td>
      </tr>';
      dbms_lob.writeappend(l_details_file, length(l_file_part), l_file_part);
    end loop;
    return l_details_file;
  end;

  /******************
  * public definitions
  */
  function table_exists(a_table_name varchar2) return boolean is
    l_count integer;
  begin
    select count(1) into l_count from user_tables where table_name = a_table_name;
    return l_count = 1;
  end;

  function sequence_exists(a_sequence_name varchar2) return boolean is
    l_count integer;
  begin
    select count(1) into l_count from user_sequences where sequence_name = a_sequence_name;
    return l_count = 1;
  end;

  procedure check_and_create_objects is
  begin
    if not sequence_exists('PLSQL_PROFILER_RUNNUMBER') then
      execute immediate 'create sequence plsql_profiler_runnumber start with 1 nocache';
    end if;
    if not table_exists('PLSQL_PROFILER_RUNS') then
      execute immediate 'create table plsql_profiler_runs
        (
          runid           number primary key,  -- unique run identifier,
                                               -- from plsql_profiler_runnumber
          related_run     number,              -- runid of related run (for client/
                                               --     server correlation)
          run_owner       varchar2(32),        -- user who started run
          run_date        date,                -- start time of run
          run_comment     varchar2(2047),      -- user provided comment for this run
          run_total_time  number,              -- elapsed time for this run
          run_system_info varchar2(2047),      -- currently unused
          run_comment1    varchar2(2047),      -- additional comment
          spare1          varchar2(256)        -- unused
        )';
    end if;
    if not table_exists('PLSQL_PROFILER_UNITS') then
      execute immediate 'create table plsql_profiler_units
        (
          runid              number references plsql_profiler_runs,
          unit_number        number,           -- internally generated library unit #
          unit_type          varchar2(32),     -- library unit type
          unit_owner         varchar2(32),     -- library unit owner name
          unit_name          varchar2(32),     -- library unit name
          -- timestamp on library unit, can be used to detect changes to
          -- unit between runs
          unit_timestamp     date,
          total_time         number DEFAULT 0 NOT NULL,
          spare1             number,           -- unused
          spare2             number,           -- unused
          --
          primary key (runid, unit_number)
        )';
    end if;
    if not table_exists('PLSQL_PROFILER_DATA') then
      execute immediate 'create table plsql_profiler_data
        (
          runid           number,           -- unique (generated) run identifier
          unit_number     number,           -- internally generated library unit #
          line#           number not null,  -- line number in unit
          total_occur     number,           -- number of times line was executed
          total_time      number,           -- total time spent executing line
          min_time        number,           -- minimum execution time for this line
          max_time        number,           -- maximum execution time for this line
          spare1          number,           -- unused
          spare2          number,           -- unused
          spare3          number,           -- unused
          spare4          number,           -- unused
          --
          primary key (runid, unit_number, line#),
          foreign key (runid, unit_number) references plsql_profiler_units
        )';
    end if;
  end;

  function profiler_start(a_run_comment varchar2 := ut_utils.to_string(systimestamp) ) return binary_integer is
    l_run_number  binary_integer;
  begin
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

  procedure gather_coverage_data(a_run_id integer) is
    type t_coverage_row is record(
    unit_owner    varchar2(250),
    unit_name     varchar2(250),
    line_number   integer,
    total_occur   number(38,0)
    );
    type tt_coverage_rows is table of t_coverage_row;
    l_data    tt_coverage_rows;
  begin
    reset_globals;
    --how to handle really really big coverages?
    execute immediate q'[
    select u.unit_owner, u.unit_name, d.line# as line_number, d.total_occur
      from plsql_profiler_units u, plsql_profiler_data d
     where u.runid = :a_run_id
       and u.runid = d.runid
       and u.unit_number = d.unit_number
       and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
       -- TODO - add inclusive and exclusive filtering
     order by u.unit_owner, u.unit_name, d.line#]'
      bulk collect into l_data using a_run_id;

    for i in 1 .. l_data.count loop
      if l_data(i).total_occur = 0 then
        g_coverage(l_data(i).unit_owner)(l_data(i).unit_name)(l_data(i).line_number) := 0;
      elsif l_data(i).total_occur > 0 then
        g_coverage(l_data(i).unit_owner)(l_data(i).unit_name)(l_data(i).line_number) := 1;
      end if;
    end loop;
  end;

  function get_coverage_data(a_run_id integer) return tt_coverage is
  begin
    gather_coverage_data(a_run_id);
    return g_coverage;
  end;

  function get_static_file_names return ut_varchar2_list is
    l_file_names ut_varchar2_list;
  begin
    select file_name
      bulk collect into l_file_names
      from ut_coverage_templates
     where is_static = 'Y';
    return l_file_names;
  end;

  function get_static_file(a_file_name varchar2) return clob is
  begin
    return get_file(a_file_name, 'Y');
  end;

  function get_details_file_content(a_object_owner varchar2, a_object_name varchar2) return clob is
    l_source_code      tt_source_data;
    l_coverage_data    tt_unit_coverage;
    l_object_full_name varchar2(500);
    l_total_lines      integer;
    l_relevant_lines   integer;
    l_covered_lines    integer;
    l_line             binary_integer;
    l_html_table_line  varchar2(32767);
    l_result           clob;
  begin
    if g_coverage.exists(a_object_owner) and g_coverage(a_object_owner).exists(a_object_name) then
--      dbms_output.put_line('found');
      select s.line, s.text
        bulk collect into l_source_code
        from all_source s
       where s.owner = a_object_owner
         and s.name = a_object_name
         and s.type not in ('PACKAGE')
       order by s.line;

      l_object_full_name := a_object_owner||'.'||a_object_name;

      l_total_lines   :=  l_source_code.count;
      l_coverage_data :=  g_coverage(a_object_owner)(a_object_name);
      for i in 1 .. l_source_code.count loop
        --skip procedure / function definition line as it is sometimes reported with 0 coverage, even if it was called
        if regexp_instr(l_source_code(i).text, '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)', 1, 1, 0, 'i') > 0 then
          l_coverage_data.delete(l_source_code(i).line);
        end if;
      end loop;

      l_relevant_lines := l_coverage_data.count;
      l_line := l_coverage_data.first;
      while l_line is not null loop
        -- add value of t_line_covered (0 - not covered, 1 - covered)
        l_relevant_lines := l_relevant_lines + l_coverage_data(l_line);
        l_line := l_coverage_data.next(l_line);
      end loop;

      g_run_total_lines    := g_run_total_lines    + l_total_lines;
      g_run_relevant_lines := g_run_relevant_lines + l_relevant_lines;
      g_run_covered_lines  := g_run_covered_lines  + l_covered_lines;

      --TODO compose line of index file and store in g_index_file_lines
--           <th class="left_align">Code Coverage</th>
--           <th class="right_align">Total Lines</th>
--           <th class="right_align">Relevant Lines</th>
--           <th class="right_align">Covered Lines</th>
--           <th class="right_align">Uncovered Lines</th>

      l_html_table_line := '';
      l_result := build_details_file_content(l_object_full_name, l_source_code, l_coverage_data, l_html_table_line);
    else
      dbms_output.put_line('not found');
    end if;
    return l_result;
  end;

-- -- details query
-- with coverage_source as(
--       select
--         u.unit_owner,
--         u.unit_name,
--         u.unit_type,
--         s.line as line_number,
--         d.total_occur,
--         --skip procedure / function definition line as it is sometimes reported with 0 coverage, even if it was called
--         case when
--           regexp_instr(s.text, '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)', 1, 1, 0,
--                        'i') = 0
--           then
--             case when d.total_occur > 0
--               then 1
--             else d.total_occur end
--         end       is_covered,
--         s.text as line_text
--       from plsql_profiler_units u
--         join all_source s
--           on s.owner = u.unit_owner
--              and s.name = u.unit_name
--         left join plsql_profiler_data d
--           on u.runid = d.runid
--              and u.unit_number = d.unit_number
--              and s.line = d.line#
--       where u.runid = 7
--             and s.type not in ('PACKAGE', 'TYPE')
--             and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
--     ),
--     coverage_filtered as(
--       select
--         unit_owner,
--         unit_name,
--         unit_type,
--         line_number,
--         total_occur,
--         case
--           when regexp_instr(
--                    line_text,
--                    '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)',
--                    1, 1, 0, 'i'
--                ) = 0
--           then
--             case when total_occur > 0 then 1 else total_occur end
--          end is_covered,
--          line_text
--       from coverage_source
--   ),
--   coverage_calculated as (
--     select
--       unit_owner,
--       unit_name,
--       unit_type,
--       line_number,
--       total_occur,
--       case is_covered when 1 then 'Y' when 0 then 'N' else NULL end is_covered,
--       line_text
--     from coverage_filtered
--   )
-- select
--   unit_owner, unit_name, unit_type, line_number, is_covered, line_text
-- from coverage_calculated
-- order by unit_owner, unit_name, unit_type, line_number
--
-- --totals query
-- with coverage_source as(
--       select
--         u.unit_owner,
--         u.unit_name,
--         u.unit_type,
--         s.line as line_number,
--         d.total_occur,
--         --skip procedure / function definition line as it is sometimes reported with 0 coverage, even if it was called
--         case when
--           regexp_instr(s.text, '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)', 1, 1, 0,
--                        'i') = 0
--           then
--             case when d.total_occur > 0
--               then 1
--             else d.total_occur end
--         end       is_covered,
--         s.text as line_text
--       from plsql_profiler_units u
--         join all_source s
--           on s.owner = u.unit_owner
--              and s.name = u.unit_name
--         left join plsql_profiler_data d
--           on u.runid = d.runid
--              and u.unit_number = d.unit_number
--              and s.line = d.line#
--       where u.runid = 7
--             and s.type not in ('PACKAGE', 'TYPE')
--             and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
--     ),
--     coverage_filtered as(
--       select
--         unit_owner,
--         unit_name,
--         unit_type,
--         line_number,
--         total_occur,
--         case
--           when regexp_instr(
--                    line_text,
--                    '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)',
--                    1, 1, 0, 'i'
--                ) = 0
--           then
--             case when total_occur > 0 then 1 else total_occur end
--          end is_covered,
--          line_text
--       from coverage_source
--   )
-- select
--   unit_owner, unit_name,
--   count(1) lines_count,
--   count(is_covered) coverable_lines_count,
--   sum(is_covered) covered_lines_count,
--   round(sum(is_covered) * 100 / count(is_covered),2) as coverage
-- from coverage_filtered
-- group by rollup(unit_owner, unit_name)
-- order by unit_owner, unit_name;

-- -- details query
-- with coverage_source as(
--       select
--         u.unit_owner,
--         u.unit_name,
--         s.line as line_number,
--         d.total_occur,
--         d.total_time as total_time_ns,
--         d.min_time as min_time_ns,
--         d.max_time as max_time_ns,
--         s.text as code
--       from plsql_profiler_units u
--         join all_source s
--           on s.owner = u.unit_owner
--              and s.name = u.unit_name
--         left join plsql_profiler_data d
--           on u.runid = d.runid
--              and u.unit_number = d.unit_number
--              and s.line = d.line#
--       where u.runid = 8
--             and s.type not in ('PACKAGE', 'TYPE')
--             and u.unit_type not in ('PACKAGE SPEC', 'TYPE SPEC')
--     ),
--     coverage_filtered as(
--       select
--         code,
--         unit_owner,
--         unit_name,
--         line_number,
--         --skip procedure / function definition line as it is sometimes reported with 0 coverage, even if it was called
--         case
--           when regexp_instr(
--                    code,
--                    '^\s*(((not)?(overriding|final|instantiable))*\s*(procedure|function)|end\s*;)',
--                    1, 1, 0, 'i'
--                ) = 0
--           then
--             case when total_occur > 0 then 1 else total_occur end
--         end is_covered,
--         total_occur,
--         total_time_ns,
--         min_time_ns,
--         max_time_ns
--       from coverage_source
--     ),
--     coverage_with_totals as (
--       select
--         line_number,
--         code,
--         unit_owner,
--         unit_name,
--         is_covered,
--         sum(is_covered) over(partition by unit_owner, unit_name) as unit_covered,
--         nullif(count(is_covered) over(partition by unit_owner, unit_name),0) unit_coverable,
--         count(1) over(partition by unit_owner, unit_name) as unit_lines,
--         sum(is_covered) over(partition by unit_owner) as schema_covered,
--         nullif(count(is_covered) over(partition by unit_owner),0) schema_coverable,
--         count(1) over(partition by unit_owner) as schema_lines,
--         sum(is_covered) over() as total_covered,
--         nullif(count(is_covered) over(),0) total_coverable,
--         count(1) over() as total_lines,
--         total_occur,
--         total_time_ns,
--         min_time_ns,
--         max_time_ns
--       from coverage_filtered
--     )
-- select
--   line_number,
--   code,
--   unit_owner,
--   unit_name,
--   total_occur,
--   is_covered,
--   total_time_ns,
--   min_time_ns,
--   max_time_ns,
--   nvl(round(unit_covered * 100 / unit_covered,2),0) as unit_code_coverage,
--   nvl(round(unit_covered * 100 / unit_lines,2),0) as unit_total_coverage,
--   nvl(round(schema_covered * 100 / schema_coverable,2),0) as schema_code_coverage,
--   nvl(round(schema_covered * 100 / schema_lines,2),0) as schema_total_coverage,
--   nvl(round(total_covered * 100 / total_coverable,2),0) as code_coverage,
--   nvl(round(total_covered * 100 / total_lines,2),0) as total_coverage
-- from coverage_with_totals
-- order by unit_owner, unit_name, line_number;

end;
/
