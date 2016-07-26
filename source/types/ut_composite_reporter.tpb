create or replace type body ut_composite_reporter is

  constructor function ut_composite_reporter(the_reporters ut_reporters_list default ut_reporters_list())
    return self as result is
  begin
    self.name := $$plsql_unit;
    return;
  end;

  member procedure add_reporter(self in out nocopy ut_composite_reporter, a_reporter ut_suite_reporter) is
  begin
    self.reporters.extend(1);
    self.reporters(self.reporters.last) := a_reporter;
  end;
  member procedure remove_reporter(self in out nocopy ut_composite_reporter, an_index pls_integer) is
  begin
    for i in an_index + 1 .. self.reporters.last loop
      self.reporters(i - 1) := self.reporters(i);
    end loop;
  
    self.reporters.delete(self.reporters.last);
  
  end;

  overriding member procedure begin_suite(self in out nocopy ut_composite_reporter, a_suite_name in varchar2) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).begin_suite(a_suite_name => a_suite_name);
    end loop;
  end;
  overriding member procedure begin_test(self in out nocopy ut_composite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).begin_test(a_test_name => a_test_name, a_test_call_params => a_test_call_params);
    end loop;
  end;
  overriding member procedure end_test(self in out nocopy ut_composite_reporter, a_test_name in varchar2, a_test_call_params in ut_test_call_params, a_execution_result in ut_execution_result, a_assert_list in ut_assert_list) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).end_test(a_test_name        => a_test_name
                                ,a_test_call_params => a_test_call_params
                                ,a_execution_result => a_execution_result
                                ,a_assert_list      => a_assert_list);
    end loop;
  end;
  overriding member procedure end_suite(self in out nocopy ut_composite_reporter, a_suite_name in varchar2, a_suite_execution_result in ut_execution_result) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).end_suite(a_suite_name => a_suite_name, a_suite_execution_result => a_suite_execution_result);
    end loop;
  end;

end;
/
