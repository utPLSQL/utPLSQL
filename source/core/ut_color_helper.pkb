create or replace package body ut_color_helper as
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

  function color_enabled return boolean is
  begin
    return g_enabled;
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
