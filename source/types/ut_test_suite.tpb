create or replace type body ut_test_suite is

  constructor function ut_test_suite(a_suite_name varchar2, a_items ut_test_objects_list default ut_test_objects_list())
    return self as result is
  begin
    self.name  := a_suite_name;
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
    if reporter is not null then
      reporter.begin_suite(self.name);
    end if;
  
    $if $$ut_trace $then
    dbms_output.put_line('ut_test_suite.execute');
    $end
  
    self.execution_result := ut_execution_result;
  
    for i in self.items.first .. self.items.last loop
      self.items(i).execute(a_reporter => reporter);
    end loop;
  
    self.execution_result.end_time := current_timestamp;
  
    for i in self.items.first .. self.items.last loop
      if (self.execution_result.result = ut_utils.tr_success and self.items(i)
         .execution_result.result in (ut_utils.tr_failure, ut_utils.tr_error)) or
         (self.execution_result.result = ut_utils.tr_failure and self.items(i)
         .execution_result.result = ut_utils.tr_error) then
        self.execution_result.result := self.items(i).execution_result.result;
      end if;
    
      exit when self.execution_result.result = ut_utils.tr_error;
    end loop;
  
    if reporter is not null then
      reporter.end_suite(self.name, self.execution_result);
    end if;
  end;

  overriding member procedure execute(self in out nocopy ut_test_suite) is
	 v_null_reporter ut_suite_reporter;
  begin
    self.execute(v_null_reporter);
  end;

end;
/
