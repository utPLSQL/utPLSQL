create or replace type body ut_test_suite is

  constructor function ut_test_suite(a_suite_name varchar2, a_items ut_test_objects_list default ut_test_objects_list())
    return self as result is
  begin
    self.name  := a_suite_name;
    self.items := a_items;
    return;
  end ut_test_suite;

  member procedure add_test(self in out nocopy ut_test_suite, a_item ut_test_object) is
  begin
    self.items.extend;
    self.items(self.items.last) := a_item;
  end add_test;

  overriding member procedure execute(self in out nocopy ut_test_suite, a_reporter in ut_suite_reporter) is
  begin
    if a_reporter is not null then
      a_reporter.begin_suite(self.name);
    end if;
  
    $if $$ut_trace $then
    dbms_output.put_line('ut_test_suite.execute');
    $end
  
    self.execution_result := ut_execution_result;
  
    for i in self.items.first .. self.items.last loop
      self.items(i).execute(a_reporter => a_reporter);
    end loop;
  
    self.execution_result.end_time := current_timestamp;
  
    for i in self.items.first .. self.items.last loop
      if (self.execution_result.result = ut_types.tr_success and self.items(i)
         .execution_result.result in (ut_types.tr_failure, ut_types.tr_error)) or
         (self.execution_result.result = ut_types.tr_failure and self.items(i)
         .execution_result.result = ut_types.tr_error) then
        self.execution_result.result := self.items(i).execution_result.result;
      end if;
    
      exit when self.execution_result.result = ut_types.tr_error;
    end loop;
  
    if a_reporter is not null then
      a_reporter.end_suite(self.name, self.execution_result);
    end if;
  end;

  overriding member procedure execute(self in out nocopy ut_test_suite) is
  begin
    self.execute(cast(null as ut_suite_reporter));
  end;

end;
/
