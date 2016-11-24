create or replace type ut_output_dbms_pipe under ut_output_stream (
  constructor function ut_output_dbms_pipe(self in out nocopy ut_output_dbms_pipe) return self as result,
  overriding member procedure open(self in out nocopy ut_output_dbms_pipe),
  overriding member procedure send_line(self in out nocopy ut_output_dbms_pipe, a_text varchar2),
  overriding member procedure send_clob(self in out nocopy ut_output_dbms_pipe, a_text clob),
  overriding member procedure close(self in out nocopy ut_output_dbms_pipe, a_timeout_sec integer),
  overriding member function get_lines(a_output_id varchar2, a_timeout_sec naturaln) return ut_varchar2_list pipelined,
  overriding final member function get_clob_lines(a_output_id varchar2, a_timeout_sec naturaln) return ut_clob_list pipelined
) not final
/
