create or replace package ut_coverage_report_html_helper authid current_user is

  function get_index(a_coverage_data ut_coverage.t_coverage, a_project_name varchar2 := null, a_command_line varchar2 := null) return clob;

end;
/
