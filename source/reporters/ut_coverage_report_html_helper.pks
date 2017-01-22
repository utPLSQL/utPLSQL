create or replace package ut_coverage_report_html_helper is

  procedure init(a_coverage_data ut_coverage.t_coverage);

  function get_details_file_content(a_object_owner varchar2, a_object_name varchar2) return clob;

  function get_index_file return clob;
end;
/
