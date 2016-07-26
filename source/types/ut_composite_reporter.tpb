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

  overriding member procedure begin_suite(self in out nocopy ut_composite_reporter, a_suite ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).begin_suite(a_suite => a_suite);
    end loop;
  end;
  overriding member procedure begin_test(self in out nocopy ut_composite_reporter, a_test ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).begin_test(a_test => a_test);
    end loop;
  end;
  overriding member procedure on_assert(self in out nocopy ut_composite_reporter, an_assert ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).on_assert(an_assert => an_assert);
    end loop;
  end;
  overriding member procedure end_test(self in out nocopy ut_composite_reporter, a_test ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).end_test(a_test => a_test);
    end loop;
  end;
  overriding member procedure end_suite(self in out nocopy ut_composite_reporter, a_suite ut_object) is
  begin
    for i in 1 .. self.reporters.count loop
      self.reporters(i).end_suite(a_suite => a_suite);
    end loop;
  end;

end;
/
