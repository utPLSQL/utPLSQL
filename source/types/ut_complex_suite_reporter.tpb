create or replace type body ut_complex_suite_reporter is

  -- Member procedures and functions
  constructor function ut_complex_suite_reporter return self as result is
  begin
    self.name      := $$plsql_unit;
    self.reporters := ut_suite_reporters();
    return;
  end;

  member procedure add_reporter(self in out nocopy ut_complex_suite_reporter, a_reporter ut_suite_reporter) is
  begin
    self.reporters.extend;
    self.reporters(self.reporters.last) := a_reporter;
  end add_reporter;

  overriding member procedure begin_suite(self in ut_complex_suite_reporter, a_suite_name in varchar2) as
  begin
    for i in self.reporters.first .. self.reporters.last loop
      self.reporters(i).begin_suite(a_suite_name);
    end loop;
  end;

  overriding member procedure end_suite(self in ut_complex_suite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result) as
  begin
    for i in self.reporters.first .. self.reporters.last loop
      self.reporters(i).end_suite(a_suite_name,a_suite_execution_result);
    end loop;
  end;

  overriding member procedure begin_test(self in ut_complex_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params) as
  begin
    for i in self.reporters.first .. self.reporters.last loop
      self.reporters(i).begin_test(a_test_name, a_test_call_params);
    end loop;
  end;

  overriding member procedure end_test(self in ut_complex_suite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list) as
  begin
    for i in self.reporters.first .. self.reporters.last loop
      self.reporters(i).end_test(a_test_name, a_test_call_params, a_execution_result, a_assert_list);
    end loop;
  end;

end;
/
