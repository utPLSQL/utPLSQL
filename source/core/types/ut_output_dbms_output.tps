create or replace type ut_output_dbms_output under ut_output (
  constructor function ut_output_dbms_output(self in out nocopy ut_output_dbms_output) return self as result,
  overriding member procedure open(self in out nocopy ut_output_dbms_output),
  overriding member procedure send_line(self in out nocopy ut_output_dbms_output, a_text varchar2),
  overriding member procedure send_clob(self in out nocopy ut_output_dbms_output, a_text clob),
  overriding member procedure close(self in out nocopy ut_output_dbms_output),
  overriding final member function get_lines(a_output_id varchar2) return ut_varchar2_list pipelined,
  overriding final member function get_clob_lines(a_output_id varchar2) return ut_clob_list pipelined
) not final
/
