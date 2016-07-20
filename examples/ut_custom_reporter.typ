create or replace type ut_custom_reporter under ut_dbms_output_suite_reporter
(
-- Author  : PAZZZ
-- Created : 20.07.2016 22:51:51
-- Purpose : 

-- Attributes
  lvl integer,
	tab_size integer,

-- Member functions and procedures
  constructor function ut_custom_reporter(a_tab_size integer default 4) return self as result,
  member function tab(self in ut_custom_reporter) return varchar2,
  overriding member procedure print(msg varchar2),
	
  overriding member procedure begin_suite(self in out nocopy ut_custom_reporter, a_suite_name in varchar2),
  overriding member procedure end_suite(self in out nocopy ut_custom_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result),
  overriding member procedure begin_test(self in out nocopy ut_custom_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params),
  overriding member procedure end_test(self in out nocopy ut_custom_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list)
)
not final
/
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
	
  overriding member procedure begin_suite(self in out nocopy ut_custom_reporter, a_suite_name in varchar2) as
  begin
		(self as ut_dbms_output_suite_reporter).begin_suite(a_suite_name);
		lvl := lvl + 1;
  end;

  overriding member procedure end_suite(self in out nocopy ut_custom_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result) as
  begin
		lvl := lvl - 1;
		(self as ut_dbms_output_suite_reporter).end_suite(a_suite_name,a_suite_execution_result);
  end;

  overriding member procedure begin_test(self in out nocopy ut_custom_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params) as
  begin
		(self as ut_dbms_output_suite_reporter).begin_test(a_test_name,a_test_call_params);
    lvl := lvl + 1;
  end;

  overriding member procedure end_test(self in out nocopy ut_custom_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list) as
  begin
    lvl := lvl - 1;
		(self as ut_dbms_output_suite_reporter).end_test(a_test_name, a_test_call_params, a_execution_result, a_assert_list);
  end;
	
end;
/
