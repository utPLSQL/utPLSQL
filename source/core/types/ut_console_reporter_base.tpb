create or replace type body ut_console_reporter_base is

  static procedure set_color_enabled(a_flag boolean) is
  begin
    ut_ansiconsole_helper.color_enabled(a_flag);
  end;

  member procedure print_red_text(self in out nocopy ut_console_reporter_base, a_text varchar2) is
  begin
    self.print_text(ut_ansiconsole_helper.red(a_text));
  end;

  member procedure print_green_text(self in out nocopy ut_console_reporter_base, a_text varchar2) is
  begin
    self.print_text(ut_ansiconsole_helper.green(a_text));
  end;

  member procedure print_yellow_text(self in out nocopy ut_console_reporter_base, a_text varchar2) is
  begin
    self.print_text(ut_ansiconsole_helper.yellow(a_text));
  end;

  member procedure print_blue_text(self in out nocopy ut_console_reporter_base, a_text varchar2) is
  begin
    self.print_text(ut_ansiconsole_helper.red(a_text));
  end;

  member procedure print_cyan_text(self in out nocopy ut_console_reporter_base, a_text varchar2) is
  begin
    self.print_text(ut_ansiconsole_helper.cyan(a_text));
  end;

  member procedure print_magenta_text(self in out nocopy ut_console_reporter_base, a_text varchar2) is
  begin
    self.print_text(ut_ansiconsole_helper.magenta(a_text));
  end;

end;
/
