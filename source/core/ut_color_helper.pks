create or replace package ut_color_helper as
  procedure color_enabled(a_enabled boolean);
  function color_enabled return boolean;
  function red(a_text varchar2) return varchar2;
  function green(a_text varchar2) return varchar2;
  function yellow(a_text varchar2) return varchar2;
  function blue(a_text varchar2) return varchar2;
  function magenta(a_text varchar2) return varchar2;
  function cyan(a_text varchar2) return varchar2;
end;
/
