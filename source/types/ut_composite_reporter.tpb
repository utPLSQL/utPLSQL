create or replace type body ut_composite_reporter is

  constructor function ut_composite_reporter(a_reporters ut_reporters_list default ut_reporters_list())
    return self as result is
  begin
    self.name := $$plsql_unit;
    reporters := a_reporters;
    return;
  end;

  member procedure add_reporter(self in out nocopy ut_composite_reporter, a_reporter ut_reporter) is
  begin
    self.reporters.extend(1);
    self.reporters(self.reporters.last) := a_reporter;
  end;
  member procedure remove_reporter(self in out nocopy ut_composite_reporter, a_index pls_integer) is
  begin
    for i in a_index + 1 .. self.reporters.last loop
      self.reporters(i - 1) := self.reporters(i);
    end loop;
  
    self.reporters.delete(self.reporters.last);
  
  end;
	
  overriding member procedure before_execution(self in out nocopy ut_composite_reporter, a_suites in ut_objects_list) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_execution(a_suites => a_suites);
    end loop;
  end;

  overriding member procedure before_suite(self in out nocopy ut_composite_reporter, a_suite in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_suite(a_suite => a_suite);
    end loop;
  end;

  overriding member procedure on_suite_setup(self in out nocopy ut_composite_reporter, a_suite in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_suite_setup(a_suite => a_suite);
    end loop;
  end;

  overriding member procedure before_test(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_test(a_test => a_test);
    end loop;
  end;

  overriding member procedure on_test_setup(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_test_setup(a_test => a_test);
    end loop;
  end;
  overriding member procedure on_test_execute(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_test_execute(a_test => a_test);
    end loop;
  end;
  overriding member procedure on_test_teardown(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_test_teardown(a_test => a_test);
    end loop;
  end;

  overriding member procedure before_asserts_process(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_asserts_process(a_test => a_test);
    end loop;
  end;
  overriding member procedure on_assert_process(self in out nocopy ut_composite_reporter, a_assert in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_assert_process(a_assert => a_assert);
    end loop;
  end;
  overriding member procedure after_asserts_process(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_asserts_process(a_test => a_test);
    end loop;
  end;

  overriding member procedure after_test(self in out nocopy ut_composite_reporter, a_test in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_test(a_test => a_test);
    end loop;
  end;

  overriding member procedure on_suite_teardown(self in out nocopy ut_composite_reporter, a_suite in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_suite_teardown(a_suite => a_suite);
    end loop;
  end;

  overriding member procedure after_suite(self in out nocopy ut_composite_reporter, a_suite in ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_suite(a_suite => a_suite);
    end loop;
  end;

  overriding member procedure after_execution(self in out nocopy ut_composite_reporter, a_suites in ut_objects_list) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_execution(a_suites => a_suites);
    end loop;
  end;	
	

end;
/
