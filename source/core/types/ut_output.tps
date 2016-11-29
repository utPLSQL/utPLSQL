create or replace type ut_output as object (
  output_type varchar2(128),
  output_id   varchar2(128),
  final member function generate_output_id return varchar2,
  not instantiable member procedure open(self in out nocopy ut_output),
  not instantiable member procedure send_line(self in out nocopy ut_output, a_text varchar2),
  not instantiable member procedure send_clob(self in out nocopy ut_output, a_text clob),
  not instantiable member procedure close(self in out nocopy ut_output),
  not instantiable member function get_lines(a_output_id varchar2) return ut_varchar2_list pipelined,
  not instantiable member function get_clob_lines(a_output_id varchar2) return ut_clob_list pipelined
) not final not instantiable
/
