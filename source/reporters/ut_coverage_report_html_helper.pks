create or replace package ut_coverage_report_html_helper is

  procedure init(a_coverage_data ut_coverage.tt_coverage);

  function get_static_file_names return ut_varchar2_list;

  function get_static_file(a_file_name varchar2) return clob;

  function get_details_file_content(a_object_owner varchar2, a_object_name varchar2) return clob;

end;
/
