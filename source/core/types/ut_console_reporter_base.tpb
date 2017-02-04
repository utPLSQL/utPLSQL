create or replace type body ut_console_reporter_base is
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

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
