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

  function executions_per_line(a_executions number, a_lines integer) return integer is
  begin
    return nvl(a_executions/nullif(a_lines,0),0);
  end;

  function line_hits_css_class(a_line_hist number) return varchar2 is
  begin
    return
      case
        when a_line_hist > 1 then
           gc_green_css
        when a_line_hist = 1 then
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

  function link_to_source_file(a_object_full_name varchar2) return varchar2 is
  begin
    return '%(<a href="#'||object_id(a_object_full_name)||'" class="src_link" title="'||a_object_full_name||'">'||a_object_full_name||'</a>)';
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

  function get_index_file return clob is
    l_file_part     varchar2(32767);
    l_title         varchar2(100) := 'All files';
    l_coverage_pct  number(5,2) := coverage_pct(g_coverage.covered_lines, g_coverage.uncovered_lines);
    l_result        clob;
    l_id            varchar2(50) := sys_guid();
    l_unit_coverage ut_coverage.t_unit_coverage;
    l_schema        ut_coverage.t_schema_name;
    l_unit          ut_coverage.t_object_name;
  begin
    dbms_lob.createtemporary(l_result,true);

    l_file_part := '<div class="file_list_container" id="'||l_id||'">
  <h2>
    <span class="group_name">'||l_title||'</span>
    (<span class="covered_percent"><span class="'||coverage_css_class(l_coverage_pct)||'">'||l_coverage_pct||'%</span></span>
     covered at
     <span class="covered_strength">
       <span class="'||line_hits_css_class(executions_per_line(g_coverage.executions, g_coverage.uncovered_lines + g_coverage.covered_lines))||'">
         '||executions_per_line(g_coverage.executions, g_coverage.uncovered_lines + g_coverage.covered_lines)||'
       </span>
    </span> hits/line)
  </h2>
  <a name="'||l_id||'"></a>
  <div>
    <b>'||g_coverage.objects||'</b> files in total.
    <b>'||(g_coverage.uncovered_lines + g_coverage.covered_lines)||'</b> relevant lines.
    <span class="green"><b>'||g_coverage.covered_lines||'</b> lines covered</span> and
    <span class="red"><b>'||g_coverage.uncovered_lines||'</b> lines missed </span>
  </div>
  <table class="file_list">
    <thead>
      <tr>
        <th>File</th>
        <th>% covered</th>
        <th>Lines</th>
        <th>Relevant Lines</th>
        <th>Lines covered</th>
        <th>Lines missed</th>
        <th>Avg. Hits / Line</th>
      </tr>
    </thead>
    <tbody>';
    dbms_lob.writeappend(l_result, length(l_file_part), l_file_part);
    l_schema := g_coverage.schemes.first;
    loop
      exit when l_schema is null;
      l_unit := g_coverage.schemes(l_schema).units.first;
      loop
        l_unit_coverage := g_coverage.schemes(l_schema).units(l_unit);
        l_file_part := '
        <tr>
          <td class="strong">'||link_to_source_file(l_schema||'.'||l_unit)||'</td>
          <td class="'||coverage_pct(l_unit_coverage.covered_lines, l_unit_coverage.uncovered_lines)||'<%= coverage_css_class(source_file.covered_percent) %> strong"><%= source_file.covered_percent.round(2).to_s %> %</td>
          <td>'||l_unit_coverage.lines.count||'</td>
          <td>'||(l_unit_coverage.covered_lines+l_unit_coverage.uncovered_lines)||'</td>
          <td>'||l_unit_coverage.covered_lines||'</td>
          <td>'||l_unit_coverage.uncovered_lines||'</td>
          <td>'||executions_per_line(l_unit_coverage.executions, l_unit_coverage.uncovered_lines + l_unit_coverage.covered_lines)||'</td>
        </tr>';
        dbms_lob.writeappend(l_result, length(l_file_part), l_file_part);
        l_unit := g_coverage.schemes(l_schema).units.next(l_unit);
      end loop;
      l_schema := g_coverage.schemes.next(l_schema);
    end loop;
    l_file_part := '
    </tbody>
  </table>
</div>
';
    dbms_lob.writeappend(l_result, length(l_file_part), l_file_part);
    return l_result;
  end;

  function get_index return clob is
    l_file_part     varchar2(32767);
    l_result        clob;
  begin
    dbms_lob.createtemporary(l_result,true);
    --TODO - build main file containing total run data and per schema data
      l_file_part :=
    '<!DOCTYPE html>
<html xmlns=''http://www.w3.org/1999/xhtml''>
  <head>
    <title>Code coverage for <%= SimpleCov.project_name %></title>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <script src=''<%= assets_path(''application.js'') %>'' type=''text/javascript''></script>
    <link href=''<%= assets_path(''application.css'') %>'' media=''screen, projection, print'' rel=''stylesheet'' type=''text/css''>
    <link rel="shortcut icon" type="image/png" href="<%= assets_path("favicon_#{coverage_css_class(result.source_files.covered_percent)}.png") %>" />
    <link rel="icon" type="image/png" href="<%= assets_path(''favicon.png'') %>" />
  </head>

  <body>
    <div id="loading">
      <img src="<%= assets_path(''loading.gif'') %>" alt="loading"/>
    </div>
    <div id="wrapper" style="display:none;">
      <div class="timestamp">Generated <%= timeago(Time.now) %></div>
      <ul class="group_tabs"></ul>

      <div id="content">
        <%= formatted_file_list("All Files", result.source_files) %>

        <% result.groups.each do |name, files| %>
          <%= formatted_file_list(name, files) %>
        <% end %>
      </div>

      <div id="footer">
        Generated by <a href="http://github.com/colszowka/simplecov">simplecov</a> v<%= SimpleCov::VERSION %>
        and simplecov-html v<%= SimpleCov::Formatter::HTMLFormatter::VERSION %><br/>
        using <%= result.command_name %>
      </div>

      <div class="source_files">
      <% result.source_files.each do |source_file| %>
        <%= formatted_source_file(source_file) %>
      <% end %>
      </div>
    </div>
  </body>
</html>
';
    return l_result;
  end;

  function get_file_names return ut_varchar2_list is
  begin
    --TODO return file names to be created
    return null;
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


end;
/
