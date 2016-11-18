create or replace type ut_output_dbms_pipe under ut_output (
  constructor function ut_output_dbms_pipe(self in out nocopy ut_output_dbms_pipe) return self as result,
  overriding member procedure open(self in out nocopy ut_output_dbms_pipe),
  overriding member procedure send_line(self in out nocopy ut_output_dbms_pipe, a_text varchar2),
  overriding member procedure send_clob(self in out nocopy ut_output_dbms_pipe, a_text clob),
  overriding member procedure close(self in out nocopy ut_output_dbms_pipe),
  static function get_lines(a_output_id varchar2, a_timeout_sec integer := 60*60*4) return ut_output_clob_list pipelined
) not final
/
