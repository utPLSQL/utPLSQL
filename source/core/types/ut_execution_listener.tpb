create or replace type body ut_execution_listener is

  member procedure fire_before_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item) is
    begin
      self.fire_event('before', a_event_name, a_item);
    end;

  member procedure fire_after_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item) is
    begin
      self.fire_event('after', a_event_name, a_item);
    end;

  member procedure fire_event(self in out nocopy ut_execution_listener, event_timing varchar2, a_event_name varchar2, a_item ut_suite_item) is
    begin
      execute immediate 'declare ' ||
                        '  l_listener ut_execution_listener := :a_listener;' ||
                        'begin ' ||
                        '  l_listener.'||event_timing||'_calling_'||a_event_name||'( :a_item );' ||
                        '  :a_result := l_listener;' ||
                        'end;' using in self, in a_item, out self;
    end;

  member procedure before_run(self in out nocopy ut_execution_listener, a_suites in ut_suite_items) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_run(a_suites => a_suites);
    end loop;
  end;

  member procedure after_run(self in out nocopy ut_execution_listener, a_suites in ut_suite_items) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_run(a_suites => a_suites);
    end loop;
  end;

  -- suite hooks
  member procedure before_suite(self in out nocopy ut_execution_listener, a_suite in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_suite(a_suite => a_suite);
    end loop;
  end;

  member procedure before_calling_before_all(self in out nocopy ut_execution_listener, a_suite in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_suite_setup(a_suite => a_suite);
    end loop;
  end;

  member procedure after_calling_before_all(self in out nocopy ut_execution_listener, a_suite in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_suite_setup(a_suite => a_suite);
    end loop;
  end;

  member procedure before_suite_item(self in out nocopy ut_execution_listener, a_suite in ut_suite_item, a_item_index pls_integer) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_suite_item(a_suite => a_suite, a_item_index => a_item_index);
    end loop;
  end;

  member procedure after_suite_item(self in out nocopy ut_execution_listener, a_suite in ut_suite_item, a_item_index pls_integer) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_suite_item(a_suite => a_suite, a_item_index => a_item_index);
    end loop;
  end;

  member procedure before_calling_after_all(self in out nocopy ut_execution_listener, a_suite in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_suite_teardown(a_suite => a_suite);
    end loop;
  end;
  
  member procedure after_calling_after_all(self in out nocopy ut_execution_listener, a_suite in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_suite_teardown(a_suite => a_suite);
    end loop;
  end;

  member procedure after_suite(self in out nocopy ut_execution_listener, a_suite in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_suite(a_suite => a_suite);
    end loop;
  end;

  -- test hooks
  member procedure before_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_test(a_test => a_test);
    end loop;
  end;

  member procedure before_calling_before_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_test_setup(a_test => a_test);
    end loop;
  end;

  member procedure after_calling_before_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_test_setup(a_test => a_test);
    end loop;
  end;

  member procedure before_calling_test_execute(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_test_execute(a_test => a_test);
    end loop;
  end;
  
  member procedure after_calling_test_execute(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_test_execute(a_test => a_test);
    end loop;
  end;

  member procedure before_calling_after_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).before_test_teardown(a_test => a_test);
    end loop;
  end;
  
  member procedure after_calling_after_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_test_teardown(a_test => a_test);
    end loop;
  end;

  member procedure after_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).after_test(a_test => a_test);
    end loop;
  end;

end;
/
