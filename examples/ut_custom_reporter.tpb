create or replace type body ut_custom_reporter is

  constructor function ut_custom_reporter(a_tab_size integer default 4) return self as result is
  begin
    self.name := $$plsql_unit;
    self.lvl  := 0;
    self.tab_size := a_tab_size;
    return;
  end;

  member function tab(self in ut_custom_reporter) return varchar2 is
	  tab_str varchar2(255);
  begin
		tab_str := rpad(' ', lvl * tab_size);
    return tab_str;
  end tab;

  overriding member procedure print(msg varchar2) is
  begin
    (self as ut_dbms_output_suite_reporter).print(tab || msg);
  end print;

  overriding member procedure begin_suite(self in out nocopy ut_custom_reporter, a_suite ut_object) as
  begin
    (self as ut_dbms_output_suite_reporter).begin_suite(a_suite);
    lvl := lvl + 1;
  end;

  overriding member procedure begin_test(self in out nocopy ut_custom_reporter, a_test ut_object) as
  begin
    (self as ut_dbms_output_suite_reporter).begin_test(a_test);
    lvl := lvl + 1;
  end;
	
	overriding member procedure on_assert(self in out nocopy ut_custom_reporter, a_assert ut_object) is
	begin
		lvl := lvl + 1;
    (self as ut_dbms_output_suite_reporter).on_assert(a_assert);
    lvl := lvl - 1;
	end;

  overriding member procedure end_test(self in out nocopy ut_custom_reporter, a_test ut_object) as
  begin
    lvl := lvl - 1;
    (self as ut_dbms_output_suite_reporter).end_test(a_test);
  end;

  overriding member procedure end_suite(self in out nocopy ut_custom_reporter, a_suite ut_object) as
  begin
    lvl := lvl - 1;
    (self as ut_dbms_output_suite_reporter).end_suite(a_suite);
  end;
	
end;
/
