create or replace type ut_output_stream under ut_output(
  overriding final member procedure close(self in out nocopy ut_output_stream),
  not instantiable member procedure close(self in out nocopy ut_output_stream, a_timeout_sec integer),
  overriding final member function get_lines(a_output_id varchar2) return ut_varchar2_list pipelined,
  not instantiable member function get_lines(a_output_id varchar2, a_timeout_sec naturaln) return ut_varchar2_list pipelined,
  overriding final member function get_clob_lines(a_output_id varchar2) return ut_clob_list pipelined,
  not instantiable member function get_clob_lines(a_output_id varchar2, a_timeout_sec naturaln) return ut_clob_list pipelined
) not final not instantiable
/
