create or replace type ut_output as object (
  output_type varchar2(128),
  output_id   varchar2(128),
  final member function generate_output_id return varchar2,
  not instantiable member procedure open(self in out nocopy ut_output),
  not instantiable member procedure send_line(self in out nocopy ut_output, a_text varchar2),
  not instantiable member procedure send_clob(self in out nocopy ut_output, a_text clob),
  not instantiable member procedure close(self in out nocopy ut_output)
) not final not instantiable
/
