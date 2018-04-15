create or replace package body ut_coverage_report_html_helper is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project
  
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
    return rawtohex(utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5(input_string => a_object_full_name)));
  end;

  function link_to_source_file(a_object_full_name varchar2) return varchar2 is
  begin
    return '<a href="#' || object_id(a_object_full_name) || '" class="src_link" title="' || a_object_full_name || '">' || a_object_full_name || '</a>';
  end;

  /*
  * public definitions
  */
  function get_index(a_coverage_data ut_coverage.t_coverage, a_assets_path varchar2, a_project_name varchar2 := null, a_command_line varchar2 := null)
    return clob is
    l_result        clob;
begin   
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      l_result := ut_extended_report_html_helper.get_index(a_coverage_data => a_coverage_data, a_assets_path => a_assets_path,a_project_name=>a_project_name,a_command_line=> a_command_line);
    $else
      l_result := ut_proftab_report_html_helper.get_index(a_coverage_data => a_coverage_data, a_assets_path => a_assets_path,a_project_name=>a_project_name,a_command_line=> a_command_line);
    $end    

    return l_result;
  end;

end;
/
