PROMPT Loading file: "index.html.template"
set define off
declare
  c_file_name constant varchar2(250) := 'index.html.template';
  l_file_part varchar2(32757);
  l_file_clob clob;
begin
  dbms_lob.createtemporary(l_file_clob , true);
  l_file_part := q'{<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
  <title>ruby-plsql-spec coverage report</title>
  <link href="coverage.css" media="all" rel="stylesheet" type="text/css" />

  <script type="text/javascript" src="jquery.min.js"></script>
  <script type="text/javascript" src="jquery.tablesorter.min.js"></script>
  <script type="text/javascript" src="rcov.js"></script>
</head>
<body>
  <h1>ruby-plsql-spec coverage report</h1>


  <noscript><style type="text/css">.if_js { display:none; }</style></noscript>

  <div class="filters if_js">
    <fieldset>
      <label>Object Filter:</label>
      <select id="file_filter" class="filter">
        <option value="all_schemas">Show all</option>
<%schema_options%>
      </select>
    </fieldset>
    <fieldset>
      <label>Code Coverage Threshold:</label>
      <select id="coverage_filter" class="filter">
        <option value="all_coverage">Show All</option>
        <option value="10">&lt; 10% Coverage</option>
        <option value="20">&lt; 20% Coverage</option>
        <option value="30">&lt; 30% Coverage</option>
        <option value="40">&lt; 40% Coverage</option>
        <option value="50">&lt; 50% Coverage</option>
        <option value="60">&lt; 60% Coverage</option>
        <option value="70">&lt; 70% Coverage</option>
        <option value="80">&lt; 80% Coverage</option>
        <option value="90">&lt; 90% Coverage</option>
        <option value="100">&lt; 100% Coverage</option>
        <option value="110">= 100% Coverage</option>
      </select>
    </fieldset>
  </div>

  <div class="report_table_wrapper">
    <table class='report' id='report_table'>
      <thead>
        <tr>
          <th class="left_align">Name</th>
          <th class="right_align">Total Lines</th>
          <th class="right_align">Analyzed Lines</th>
          <th class="left_align">Total Coverage</th>
          <th class="left_align">Code Coverage</th>
        </tr>
      </thead>
      <tfoot>
table_footer_html
      </tfoot>
      <tbody>
<%table_lines_html%>
      </tbody>
    </table>
  </div>

  <p>Generated at <%timestamp%> with <a href="https://github.com/utPLSQL/utPLSQL/">UTPLSQL</a>
    using <a href="http://github.com/relevance/rcov">rcov</a> template.</p>

</body>
</html>
}';

  dbms_lob.writeappend(l_file_clob, length(l_file_part), l_file_part);

  insert
    into ut_coverage_templates( file_name, file_content, is_static )
    values ( c_file_name, l_file_clob, 'N' );

  commit;
end;
/


-- <%schema_options%>
--   for i in 1 .. l_schemes.count loop
--     '<option value="'||i||'_schema">'||i||'</option>'
--   end loop;

--<%table_footer_html%>
--<%table_lines_html%>
--<%timestamp%>
