create or replace type ut_console_reporter_base under ut_reporter_base
(
  static procedure set_color_enabled(a_flag boolean),

  member procedure print_red_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_green_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_yellow_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_blue_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_cyan_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_magenta_text(self in out nocopy ut_console_reporter_base, a_text varchar2)

) not final not instantiable
/
