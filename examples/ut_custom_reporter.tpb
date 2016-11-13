create or replace type body ut_custom_reporter is

  constructor function ut_custom_reporter(a_tab_size integer default 4, a_output ut_output default ut_output_dbms_output() ) return self as result is
  begin
    self.name     := $$plsql_unit;
    self.lvl      := 0;
    self.tab_size := a_tab_size;
    self.output   := a_output;
    return;
  end;

  member function tab(self in ut_custom_reporter) return varchar2 is
    tab_str varchar2(255);
  begin
    tab_str := rpad(' ', lvl * tab_size);
    return tab_str;
  end tab;

  overriding member procedure print(a_text varchar2) is
  begin
    (self as ut_dbms_output_suite_reporter).print(tab || a_text);
  end print;

  overriding member procedure before_suite(self in out nocopy ut_custom_reporter, a_suite ut_object) as
  begin
    (self as ut_dbms_output_suite_reporter).before_suite(a_suite);
    lvl := lvl + 1;
  end;

  overriding member procedure before_test(self in out nocopy ut_custom_reporter, a_test ut_object) as
  begin
    (self as ut_dbms_output_suite_reporter).before_test(a_test);
    lvl := lvl + 1;
  end;

  overriding member procedure on_assert_process(self in out nocopy ut_custom_reporter, a_assert ut_object) is
  begin
    lvl := lvl + 1;
    (self as ut_dbms_output_suite_reporter).on_assert_process(a_assert);
    lvl := lvl - 1;
  end;

  overriding member procedure after_test(self in out nocopy ut_custom_reporter, a_test ut_object) as
  begin
    lvl := lvl - 1;
    (self as ut_dbms_output_suite_reporter).after_test(a_test);
  end;

  overriding member procedure after_suite(self in out nocopy ut_custom_reporter, a_suite ut_object) as
  begin
    lvl := lvl - 1;
    (self as ut_dbms_output_suite_reporter).after_suite(a_suite);
  end;

end;
/
