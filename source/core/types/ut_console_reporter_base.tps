create or replace type ut_console_reporter_base under ut_output_reporter_base(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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
  static procedure set_color_enabled(a_flag boolean),

  member procedure print_red_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_green_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_yellow_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_blue_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_cyan_text(self in out nocopy ut_console_reporter_base, a_text varchar2),

  member procedure print_magenta_text(self in out nocopy ut_console_reporter_base, a_text varchar2)

) not final not instantiable
/
