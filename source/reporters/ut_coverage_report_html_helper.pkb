create or replace package body ut_coverage_report_html_helper is

  type t_source_row is record (
    line integer,
    text varchar2(32767)
  );
  type tt_source_data is table of t_source_row;

  --holds information about coverage data for run
  g_coverage           ut_coverage.tt_coverage;

  --hold information about run coverage totals
  g_run_total_lines    integer := 0;
  g_run_relevant_lines integer := 0;
  g_run_covered_lines  integer := 0;

  --temporary clob for index file
  g_index_file_lines   clob;

  /**************
  * private definitions
  */
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

  function build_table_line(
    a_object_owner varchar2, a_object_name varchar2,
    a_total_lines integer, a_relevant_lines integer, a_covered_lines integer
  ) return varchar2 is
    l_result       varchar2(32767);
    l_object_name  varchar2(500) := upper(a_object_owner||'.'||a_object_name);
    l_coverage_pct number(3,2) := round(nvl(a_covered_lines/nullif(a_relevant_lines,0),0),2);
    l_min_cov      integer := trunc(l_coverage_pct/10)+1;
    l_max_cov      integer := case when l_coverage_pct=100 then 11 else 10 end;
  begin
    l_result :=
'    <tr class="all_schemas all_coverage '||a_object_owner||'_schema';
    for i in l_min_cov..l_max_cov loop
      l_result := l_result || ' ' || i*10;
    end loop;
    l_result := l_result ||
      '">
          <td class="left_align"><a href="'||l_object_name||'.html">'||l_object_name||'</a></td>
          <td class="right_align"><tt>'||a_covered_lines||'</tt></td>
          <td class="right_align"><tt>'||(a_relevant_lines-a_covered_lines)||'</tt></td>
          <td class="right_align"><tt>'||a_total_lines||'</tt></td>
          <td class="right_align"><tt>'||a_relevant_lines||'</tt></td>
          <td class="left_align"><div class="percent_graph_legend"><tt class="">'||l_coverage_pct||'%</tt></div>
        <div class="percent_graph">
          <div class="covered" style="width:'||round(l_coverage_pct)||'px"></div>
          <div class="uncovered" style="width: 100-'||round(l_coverage_pct)||'px"></div>
        </div></td>
    </tr>
';
    return l_result;
  end;

  function build_details_file_content(a_object_full_name varchar2, a_source_code tt_source_data,
    a_coverage_data ut_coverage.tt_unit_coverage, a_html_table_line varchar2
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
          <th class="right_align">Covered Lines</th>
          <th class="right_align">Uncovered Lines</th>
          <th class="right_align">Total Lines</th>
          <th class="right_align">Relevant Lines</th>
          <th class="left_align">Total Coverage</th>
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
        if a_coverage_data(a_source_code(i).line) then
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
  procedure init(a_coverage_data ut_coverage.tt_coverage) is
  begin
    g_coverage           := a_coverage_data;
    g_run_total_lines    := 0;
    g_run_relevant_lines := 0;
    g_run_covered_lines  := 0;
    dbms_lob.createtemporary(g_index_file_lines, true);
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
    l_coverage_data    ut_coverage.tt_unit_coverage;
    l_object_full_name varchar2(500);
    l_total_lines      integer;
    l_relevant_lines   integer;
    l_covered_lines    integer := 0;
    l_line             binary_integer;
    l_html_table_line  varchar2(32767);
    l_result           clob;
  begin
    select s.line, s.text
      bulk collect into l_source_code
      from all_source s
     where s.owner = a_object_owner
       and s.name = a_object_name
       and s.type not in ('PACKAGE')
     order by s.line;

    if g_coverage.exists(a_object_owner) and g_coverage(a_object_owner).exists(a_object_name) then

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
        if l_coverage_data(l_line) then
          l_covered_lines := l_covered_lines + 1;
        end if;
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

      l_html_table_line := build_table_line( a_object_owner, a_object_name, l_total_lines, l_relevant_lines, l_covered_lines);
      l_result := build_details_file_content(l_object_full_name, l_source_code, l_coverage_data, l_html_table_line);
    else
      --TODO - report a zero coverage on an item
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
