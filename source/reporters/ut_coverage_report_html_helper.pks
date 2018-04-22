create or replace package ut_coverage_report_html_helper authid current_user is
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
  function get_default_html_assets_path return varchar2 deterministic;

  function coverage_pct(a_covered_lines integer, a_uncovered_lines integer) return number;
  
  function coverage_css_class(a_covered_pct number) return varchar2;
  
  function line_status(a_executions in ut_coverage.t_line_executions) return varchar2;
  
  function link_to_source_file(a_object_full_name varchar2) return varchar2;
  
  function object_id(a_object_full_name varchar2) return varchar2;
  
  function executions_per_line(a_executions number, a_lines integer) return integer;
  
  function line_hits_css_class(a_line_hist number) return varchar2;
  
  function get_index(a_coverage_data ut_coverage.t_coverage, a_assets_path varchar2, a_project_name varchar2 := null, a_command_line varchar2 := null) return clob;

end;
/
