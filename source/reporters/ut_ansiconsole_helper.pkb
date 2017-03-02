create or replace package body ut_ansiconsole_helper as
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
  c_red     constant varchar2(7) := chr(27) || '[31m';
  c_green   constant varchar2(7) := chr(27) || '[32m';
  c_yellow  constant varchar2(7) := chr(27) || '[33m';
  c_blue    constant varchar2(7) := chr(27) || '[34m';
  c_magenta constant varchar2(7) := chr(27) || '[35m';
  c_cyan    constant varchar2(7) := chr(27) || '[36m';
  c_reset   constant varchar2(7) := chr(27) || '[0m';
  g_enabled boolean := false;

  procedure color_enabled(a_enabled boolean) is
  begin
    g_enabled := a_enabled;
  end;

  function add_color(a_text varchar2, a_color varchar2 := c_reset) return varchar2 is
  begin
    if g_enabled then
      return a_color||a_text||c_reset;
    else
      return a_text;
    end if;
  end;

  function red(a_text varchar2) return varchar2 is
  begin
    return add_color(a_text, c_red);
  end;

  function green(a_text varchar2) return varchar2 is
  begin
    return add_color(a_text, c_green);
  end;

  function yellow(a_text varchar2) return varchar2 is
  begin
    return add_color(a_text, c_yellow);
  end;

  function blue(a_text varchar2) return varchar2 is
  begin
    return add_color(a_text, c_blue);
  end;

  function magenta(a_text varchar2) return varchar2 is
  begin
    return add_color(a_text, c_magenta);
  end;

  function cyan(a_text varchar2) return varchar2 is
  begin
    return add_color(a_text, c_cyan);
  end;

end;
/
