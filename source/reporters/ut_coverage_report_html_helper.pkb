create or replace package body ut_coverage_report_html_helper is

  gc_green_coverage_pct  constant integer := 90;
  gc_yellow_coverage_pct constant integer := 80;
  gc_green_css           constant varchar2(10) := 'green';
  gc_yellow_css          constant varchar2(10) := 'yellow';
  gc_red_css             constant varchar2(10) := 'red';

  type tt_source_data is table of varchar2(32767);

  --holds information about coverage data for run
  g_coverage           ut_coverage.t_coverage;

  --temporary clob for index file
  g_index_file_lines   clob;

  /*
  * private definitions
  */
  function coverage_css_class(a_covered_pct integer) return varchar2 is
  begin
    return
      case
        when a_covered_pct > gc_green_coverage_pct then
           gc_green_css
        when a_covered_pct > gc_yellow_coverage_pct then
           gc_yellow_css
        else
           gc_red_css
      end;
  end;

  function coverage_pct(a_covered_lines binary_integer, a_uncovered_lines binary_integer) return number is
  begin
    return round(nvl(a_covered_lines/nullif(a_covered_lines+a_uncovered_lines,0),0)*100,2);
  end;

  function object_id(a_object_full_name varchar2) return varchar2 is
  begin
    return dbms_obfuscation_toolkit.md5(input_string=>a_object_full_name);
  end;


  function build_details_file_content( a_object_full_name varchar2, a_source_code tt_source_data, a_coverage_unit ut_coverage.t_unit_coverage ) return clob is
    l_file_part    varchar2(32767);
    l_details_file clob;
    l_coverage_pct number(5,2) := coverage_pct(a_coverage_unit.covered_lines, a_coverage_unit.uncovered_lines);
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
<body>'||
'<div class="source_table" id="'||object_id(a_object_full_name)||'">
  <div class="header">
    <h3>'||a_object_full_name||'</h3>
    <h4><span class="'||coverage_css_class(l_coverage_pct)||'">'||l_coverage_pct||' %</span> covered</h4>
    <div>
      <b>'||(a_coverage_unit.covered_lines+a_coverage_unit.uncovered_lines)||'</b> relevant lines.
      <span class="green"><b>'||a_coverage_unit.covered_lines||'</b> lines covered</span> and
      <span class="red"><b>'||a_coverage_unit.uncovered_lines||'</b> lines missed.</span>
    </div>
  </div>

  <pre>
    <ol>';
    dbms_lob.writeappend(l_details_file, length(l_file_part), l_file_part);
    for line_no in 1 .. a_source_code.count loop
     l_file_part :='
       <li class="'||a_coverage_unit.lines(line_no).status||'" data-hits="'||(a_coverage_unit.lines(line_no).executions)||'" data-linenumber="'||(line_no)||'">';
      if not a_coverage_unit.lines.exists(line_no) then
        dbms_output.put_line('line:['||line_no||'] not found.');
      end if;
      l_file_part := l_file_part ||
      case when a_coverage_unit.lines.exists(line_no) then
        case when a_coverage_unit.lines(line_no).covered then '
          <span class="hits">'||(a_coverage_unit.lines(line_no).executions)||'</span>'
          when not a_coverage_unit.lines(line_no).covered then '
          <span class="hits">skipped</span>'
        end
      end||'
          <code class="sql">'||(dbms_xmlgen.convert(a_source_code(line_no)))||'</code>
      </li>';
      dbms_lob.writeappend(l_details_file, length(l_file_part), l_file_part);
    end loop;
    l_file_part := '
    </ol>
  </pre>
</div>'||
'</body>
</html>';
 dbms_lob.writeappend(l_details_file, length(l_file_part), l_file_part);
    return l_details_file;
  end;

  /*
  * public definitions
  */
  procedure init(a_coverage_data ut_coverage.t_coverage) is
  begin
    g_coverage           := a_coverage_data;
    dbms_lob.createtemporary(g_index_file_lines, true);
  end;


  function get_details_file_content(a_object_owner varchar2, a_object_name varchar2) return clob is
    l_source_code      tt_source_data;
    l_result           clob;
  begin
    select rtrim(s.text,chr(10)) text
      bulk collect into l_source_code
      from all_source s
     where s.owner = a_object_owner
       and s.name = a_object_name
       and s.type not in ('PACKAGE')
     order by s.line;
    if g_coverage.schemes.exists(a_object_owner) and g_coverage.schemes(a_object_owner).units.exists(a_object_name) then
      l_result := build_details_file_content(a_object_owner||'.'||a_object_name, l_source_code, g_coverage.schemes(a_object_owner).units(a_object_name));
    else
      --TODO - report a zero coverage on an item
      dbms_output.put_line('not found');
    end if;
    return l_result;
  end;

  function get_index_file return clob is
    l_file_part    varchar2(32767);
    l_file         clob;
  begin
    dbms_lob.createtemporary(l_file,true);
    l_file_part := '';
    return null;
  end;

end;
/
