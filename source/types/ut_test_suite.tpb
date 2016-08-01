create or replace type body ut_test_suite is

  constructor function ut_test_suite(a_suite_name varchar2, a_items ut_objects_list default ut_objects_list())
    return self as result is
  begin
    self.name  := a_suite_name;
		self.object_type := 2;
    self.items := a_items;
    return;
  end ut_test_suite;

  member procedure add_item(self in out nocopy ut_test_suite, a_item ut_test_object) is
  begin
    self.items.extend;
    self.items(self.items.last) := a_item;
  end add_item;

  overriding member procedure execute(self in out nocopy ut_test_suite, a_reporter ut_suite_reporter) is
    reporter ut_suite_reporter := a_reporter;
  begin
    reporter := execute(reporter);
  end;

  overriding member function execute(self in out nocopy ut_test_suite, a_reporter ut_suite_reporter) return ut_suite_reporter is
    reporter ut_suite_reporter := a_reporter;
		test_object ut_test_object;
  begin
    if reporter is not null then
      reporter.begin_suite(self);
    end if;
  
    $if $$ut_trace $then
    dbms_output.put_line('ut_test_suite.execute');
    $end
  
    self.start_time := current_timestamp;
  
    for i in self.items.first .. self.items.last loop
			test_object := treat(self.items(i) as ut_test_object);
      reporter := test_object.execute(a_reporter => reporter);
			self.items(i) := test_object;
    end loop;
  
    self.end_time := current_timestamp;
		
		self.calc_execution_result;
  
    if reporter is not null then
      reporter.end_suite(self);
    end if;
    return reporter;
  end;

  overriding member procedure execute(self in out nocopy ut_test_suite) is
	 v_null_reporter ut_suite_reporter;
  begin
    self.execute(v_null_reporter);
  end;

end;
/
