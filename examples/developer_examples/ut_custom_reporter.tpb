create or replace type body ut_custom_reporter is

  constructor function ut_custom_reporter(a_tab_size integer default 4) return self as result is
  begin
    self.init($$plsql_unit);
    self.lvl      := 0;
    self.tab_size := a_tab_size;
    self.failed_test_running_count := 0;
    return;
  end;

  overriding member function tab(self in ut_custom_reporter) return varchar2 is
    tab_str varchar2(255);
  begin
    tab_str := rpad(' ', lvl * tab_size);
    return tab_str;
  end tab;

  overriding member procedure print_text(a_text varchar2, a_item_type varchar2 := null) is
  begin
    (self as ut_documentation_reporter).print_text(tab || a_text, a_item_type);
  end;

  overriding member procedure before_calling_suite(self in out nocopy ut_custom_reporter, a_suite ut_logical_suite) as
  begin
    (self as ut_documentation_reporter).before_calling_suite(a_suite);
    lvl := lvl + 1;
  end;

  overriding member procedure before_calling_test(self in out nocopy ut_custom_reporter, a_test ut_test) as
  begin
    (self as ut_documentation_reporter).before_calling_test(a_test);
    lvl := lvl + 1;
  end;

  overriding member procedure after_calling_test(self in out nocopy ut_custom_reporter, a_test ut_test) as
  begin
    lvl := lvl - 1;
    (self as ut_documentation_reporter).after_calling_test(a_test);
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_custom_reporter, a_suite ut_logical_suite) as
  begin
    lvl := lvl - 1;
    (self as ut_documentation_reporter).after_calling_suite(a_suite);
  end;

end;
/
