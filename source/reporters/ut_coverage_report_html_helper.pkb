create or replace package body ut_coverage_report_html_helper is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project
  
  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
      http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  gc_green_coverage_pct  constant integer := 90;
  gc_yellow_coverage_pct constant integer := 80;

  gc_green_css  constant varchar2(10) := 'green';
  gc_yellow_css constant varchar2(10) := 'yellow';
  gc_red_css    constant varchar2(10) := 'red';

  gc_missed      constant varchar2(7) := 'missed';
  gc_skipped     constant varchar2(7) := 'skipped';
  gc_disabled    constant varchar2(7) := 'never';
  gc_covered     constant varchar2(7) := 'covered';
  gc_partcovered constant varchar2(7) := 'partcov';

  function get_default_html_assets_path return varchar2 deterministic is
    c_assets_path constant varchar2(200) := 'https://utplsql.github.io/utPLSQL-coverage-html/assets/';
  begin
    return c_assets_path;
  end;

  function coverage_css_class(a_covered_pct number) return varchar2 is
    l_result varchar2(10);
  begin
    if a_covered_pct > gc_green_coverage_pct then
      l_result := gc_green_css;
    elsif a_covered_pct > gc_yellow_coverage_pct then
      l_result := gc_yellow_css;
    else
      l_result := gc_red_css;
    end if;
    return l_result;
  end;

  function line_status(a_executions in ut_coverage.t_line_executions) return varchar2 is
    l_result varchar2(10);
  begin
    if a_executions.executions > 0 then
      if NVL(a_executions.partcove,0) = 0 then
        l_result := gc_covered;
      else
        l_result := gc_partcovered;
      end if;
    elsif a_executions.executions = 0 then
      l_result := gc_missed;
    else
      l_result := gc_disabled;
    end if;
    return l_result;
  end;

  function executions_per_line(a_executions number, a_lines integer) return integer is
  begin
    return nvl(a_executions / nullif(a_lines, 0), 0);
  end;

  function line_hits_css_class(a_line_hist number) return varchar2 is
    l_result varchar2(10);
  begin
    if a_line_hist > 1 then
      l_result := gc_green_css;
    elsif a_line_hist = 1 then
      l_result := gc_yellow_css;
    else
      l_result := gc_red_css;
    end if;
    return l_result;
  end;

  function coverage_pct(a_covered_lines integer, a_uncovered_lines integer) return number is
  begin
    return ROUND(nvl(a_covered_lines / nullif(a_covered_lines + a_uncovered_lines, 0), 0) * 100, 2);
  end;

  function object_id(a_object_full_name varchar2) return varchar2 is
  begin
    return rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw(a_object_full_name), typ => dbms_crypto.hash_md5));
  end;

  function link_to_source_file(a_object_full_name varchar2) return varchar2 is
  begin
    return '<a href="#' || object_id(a_object_full_name) || '" class="src_link" title="' || a_object_full_name || '">' || a_object_full_name || '</a>';
  end;




  function get_details_file_content(
    a_object_id varchar2,
    a_unit ut_object_name,
    a_unit_coverage ut_coverage.t_unit_coverage
  ) return ut_varchar2_rows is

    function get_block_file_attributes(a_coverage_unit ut_coverage.t_unit_coverage) return varchar2 is
      l_result varchar2(32767);
    begin
      if (a_coverage_unit.partcovered_lines is not null) AND (a_coverage_unit.partcovered_lines > 0) then   
        l_result := ' (including <span class="yellow"><b>'|| a_coverage_unit.partcovered_lines ||'</b> lines partially covered</span> )';
      else
        l_result := null;
      end if;
      return l_result;
    end;
    
    function get_common_file_attributes(a_coverage_unit ut_coverage.t_unit_coverage) return varchar2 is
    l_attributes varchar2(32767);
    begin
    l_attributes := '<div> <b>' ||(a_coverage_unit.covered_lines + a_coverage_unit.uncovered_lines)
                    ||'</b> relevant lines. ' || '<span class="green"><b>' || a_coverage_unit.covered_lines 
                    ||'</b> lines covered</span>'
                    || get_block_file_attributes(a_coverage_unit)
                    || ' and <span class="red"><b>' || a_coverage_unit.uncovered_lines ||'</b> lines missed</span>';
      return l_attributes;
    end;   
    
    function build_details_file_content(a_object_id varchar2, a_object_full_name varchar2, a_source_code ut_varchar2_list, a_coverage_unit ut_coverage.t_unit_coverage)
      return ut_varchar2_rows is
      l_file_part           varchar2(32767);
      l_result              ut_varchar2_rows := ut_varchar2_rows();
      l_coverage_pct        number(5, 2);
      l_coverage_block_pct  number(5, 2);
      l_hits                varchar2(30);
      l_blocks              varchar2(30);
    begin

     l_coverage_pct := coverage_pct(a_coverage_unit.covered_lines, a_coverage_unit.uncovered_lines);

     l_file_part := '<div class="source_table" id="' || a_object_id || '"><div class="header"> <h3>' ||
                     dbms_xmlgen.convert(a_object_full_name) || '</h3><h4><span class="' || coverage_css_class(l_coverage_pct) || '">'
                    || l_coverage_pct || ' %</span> lines covered</h4>' 
                    ||get_common_file_attributes(a_coverage_unit) ||'</div></div><pre><ol>';
      ut_utils.append_to_list(l_result, l_file_part);
    
      for line_no in 1 .. a_source_code.count loop
        if not a_coverage_unit.lines.exists(line_no) then
          l_file_part := '
            <li class="' || line_status(null) || '" data-hits="" data-linenumber="' || line_no || '">
            <code class="sql">' || (dbms_xmlgen.convert(a_source_code(line_no))) ||
                         '</code></li>';
        else
          l_hits := to_char(a_coverage_unit.lines(line_no).executions);
          if nvl(a_coverage_unit.lines(line_no).covered_blocks,0) < nvl(a_coverage_unit.lines(line_no).no_blocks,0) 
          and nvl(a_coverage_unit.lines(line_no).partcove,0) = 1 then
            l_blocks := to_char(a_coverage_unit.lines(line_no).covered_blocks) || chr(47)||
                        to_char(a_coverage_unit.lines(line_no).no_blocks);  
          else
           l_blocks := null;
          end if;
           
          l_file_part := '
            <li class="' || line_status(a_coverage_unit.lines(line_no)) || '" data-hits="' ||
                         dbms_xmlgen.convert(l_hits)|| '"'||
                         case 
                           when l_blocks is not null 
                             then ' data-blocks="'||dbms_xmlgen.convert(l_blocks)||'"' 
                           else 
                             null 
                           end
                         ||' data-linenumber="' || (line_no) || '">';
          if a_coverage_unit.lines(line_no).executions > 0 then
            
            l_file_part := l_file_part ||
            case when l_blocks is not null
              then '
                <span class="blocks">' ||dbms_xmlgen.convert(l_blocks) ||
                '</span>'
              else
                null
              end
            || '
              <span class="hits">' || dbms_xmlgen.convert(l_hits) ||
                           '</span>';
          end if;
          l_file_part := l_file_part || '
              <code class="sql">' || (dbms_xmlgen.convert(a_source_code(line_no))) ||
                         '</code></li>';
        end if;
        ut_utils.append_to_list(l_result, l_file_part);
      end loop;
    
      l_file_part := '</ol></pre></div>';
      ut_utils.append_to_list(l_result, l_file_part);
      return l_result;
    end;
  begin
    return build_details_file_content(
      a_object_id,
      a_unit.identity,
      ut_coverage_helper.get_tmp_table_object_lines(a_unit.owner, a_unit.name),
      a_unit_coverage
    );
  end;

    function get_block_list_attributes(a_coverage_unit ut_coverage.t_coverage) return varchar2 is
      l_result varchar2(32767);
    begin
      if (a_coverage_unit.partcovered_lines is not null) AND (a_coverage_unit.partcovered_lines > 0) then   
        l_result := ' (including <span class="yellow"><b>'|| a_coverage_unit.partcovered_lines ||'</b> lines partially covered</span> )';
      else
        l_result := null;
      end if;
      return l_result;
    end;

  function file_list(a_title varchar2, a_coverage ut_coverage.t_coverage) return ut_varchar2_rows is
    l_file_part     varchar2(32767);
    l_title         varchar2(100) := 'All files';
    l_coverage_pct  number(5, 2);
    l_coverage_block_pct  number(5, 2);
    l_result        ut_varchar2_rows;
    l_id            varchar2(50) := object_id(a_title);
    l_unit_coverage ut_coverage.t_unit_coverage;
    l_unit          ut_coverage.t_object_name;
  begin
    l_coverage_pct := coverage_pct(a_coverage.covered_lines, a_coverage.uncovered_lines);

    l_file_part := '<div class="file_list_container" id="' || l_id || '">' || '<h2><span class="group_name">' || l_title ||
                   '</span>' || ' (<span class="covered_percent"><span class="' || coverage_css_class(l_coverage_pct) || '">' ||
                   l_coverage_pct || '%</span></span>' || ' lines covered'||
                   ' at <span class="covered_strength">' ||
                   '<span class="' ||line_hits_css_class(executions_per_line(a_coverage.executions
                                                             ,a_coverage.uncovered_lines + a_coverage.covered_lines)) || '">' ||
                      executions_per_line(a_coverage.executions, a_coverage.uncovered_lines + a_coverage.covered_lines)
                     || '</span></span> hits/line)</h2>' || '<a id="a_' || l_id || '"></a>' || '<div><b>' ||
                      a_coverage.objects.count || '</b> files in total. </div><div>' || '<b>' || 
                      (a_coverage.uncovered_lines + a_coverage.covered_lines)
                   || '</b> relevant lines. ' || '<span class="green"><b>' || a_coverage.covered_lines ||
                   '</b> lines covered</span>'|| get_block_list_attributes(a_coverage)
                   ||' and <span class="red"><b>' || a_coverage.uncovered_lines || '</b> lines missed.</span>'||
                   '<table class="file_list"><thead>' || '<tr>' ||
                   '<th>File</th><th>% covered</th><th>Lines</th><th>Relevant Lines</th><th>Lines covered</th><th>Lines missed</th><th>'
                   ||'Avg. Hits / Line </th>' ||
                   '</tr></thead><tbody>';
    ut_utils.append_to_list( l_result, l_file_part );
    l_unit := a_coverage.objects.first;
    loop
      exit when l_unit is null;
      l_unit_coverage := a_coverage.objects(l_unit);
      l_coverage_pct := coverage_pct(l_unit_coverage.covered_lines, l_unit_coverage.uncovered_lines);

     l_file_part := chr(10) || '<tr>' || '<td class="strong">' || link_to_source_file(dbms_xmlgen.convert(l_unit)) ||
                     '</td>' || '<td class="' || coverage_css_class(l_coverage_pct) || ' strong">' || l_coverage_pct ||
                     ' %</td>' || '<td>' || l_unit_coverage.total_lines || '</td>' || '<td>' || 
                       (l_unit_coverage.covered_lines + l_unit_coverage.uncovered_lines) || '</td>' || '<td>' ||
                       l_unit_coverage.covered_lines || '</td><td>' || l_unit_coverage.uncovered_lines || '</td>' || 
                       '<td>' || to_char(executions_per_line(l_unit_coverage.executions
                                        ,l_unit_coverage.uncovered_lines + l_unit_coverage.covered_lines))
                       || '</td></tr>';
      ut_utils.append_to_list( l_result, l_file_part );
      l_unit := a_coverage.objects.next(l_unit);
    end loop;
    l_file_part := '</tbody></table></div>';
    ut_utils.append_to_list( l_result, l_file_part );
    return l_result;
  end;

  /*
  * public definitions
  */
  function get_index(
    a_coverage_data ut_coverage.t_coverage,
    a_assets_path   varchar2,
    a_project_name  varchar2 := null,
    a_command_line  varchar2 := null,
    a_charset       varchar2 := null
  ) return ut_varchar2_rows is
  
    l_file_part     varchar2(32767);
    l_result        ut_varchar2_rows := ut_varchar2_rows();
    l_title         varchar2(250);
    l_coverage_pct  number(5, 2);
    l_time_str      varchar2(50);
    l_using         varchar2(1000);
    l_unit          ut_coverage.t_object_name;
    l_charset       varchar2(1000);
  begin
    l_charset := coalesce(upper(a_charset),'UTF-8');
    l_coverage_pct := coverage_pct(a_coverage_data.covered_lines, a_coverage_data.uncovered_lines);

    l_time_str := to_char(sysdate,'yyyy-mm-dd"T"hh24:mi:ss');
    l_using := case
                 when a_command_line is not null then
                  '<br/>using ' || dbms_xmlgen.convert(a_command_line)
               end;
    l_title := case
                 when a_project_name is null then
                  'Code coverage'
                 else
                  dbms_xmlgen.convert(a_project_name) || ' code coverage'
               end;
    --TODO - build main file containing total run data and per schema data
    l_file_part := '<!DOCTYPE html><html xmlns=''http://www.w3.org/1999/xhtml''><head>' || '<title>' || l_title ||
                   '</title>' || '<meta http-equiv="content-type" content="text/html; charset='||l_charset||'" />' ||
                   '<script src=''' || a_assets_path || 'application.js''></script>' ||
                   '<link href=''' || a_assets_path ||
                   'application.css'' media=''screen, print'' rel=''stylesheet'' type=''text/css''/>' ||
                   '<link rel="shortcut icon" type="image/png" href="' || a_assets_path || 'favicon_' ||
                   coverage_css_class(l_coverage_pct) || '.png" />' || '<link rel="icon" type="image/png" href="' ||
                   a_assets_path || 'favicon_' || coverage_css_class(l_coverage_pct) || '.png" />' || '</head>' ||
                   '<body><div id="loading"><img src="' || a_assets_path || 'loading.gif" alt="loading"/></div>' ||
                   '<div id="wrapper" style="display:none;">' ||
                   '<div class="timestamp">Generated <abbr class="timeago" title="' || l_time_str || '">' || l_time_str ||
                   '</abbr></div>' || '<ul class="group_tabs"></ul>' || '<div id="content">';
    ut_utils.append_to_list(l_result, l_file_part);

    ut_utils.append_to_list(l_result, file_list('All files', a_coverage_data));
  
    l_file_part := chr(10) || '</div><div id="footer">' ||
                   'Generated by <a href="http://github.com/utPLSQL/utPLSQL">utPLSQL ' || ut_utils.gc_version ||
                   '</a><br/>' ||
                   'Based on <a href="http://github.com/colszowka/simplecov-html">simplecov-html</a> v0.10.0 ' ||
                   l_using || '' || '</div><div class="source_files">';
    ut_utils.append_to_list(l_result, l_file_part);
  
    l_unit := a_coverage_data.objects.first;
    loop
      exit when l_unit is null;
      ut_utils.append_to_list(
        l_result,
        get_details_file_content(
          object_id(l_unit),
          ut_object_name(a_coverage_data.objects(l_unit).owner,
          a_coverage_data.objects(l_unit).name),
          a_coverage_data.objects(l_unit)
        )
      );
      l_unit := a_coverage_data.objects.next(l_unit);
    end loop;
  
    l_file_part := '</div></div></div></body></html>';
  
    ut_utils.append_to_list(l_result, l_file_part);
    return l_result;
  end;

end;
/
