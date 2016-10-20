create or replace type body ut_test_suite is

  constructor function ut_test_suite(self in out nocopy ut_test_suite,a_suite_name varchar2, a_object_name varchar2 default null, a_items ut_objects_list default ut_objects_list(), a_rollback_type number default null)
    return self as result is
  begin
    self.name        := a_suite_name;
    self.object_type := 2;
    self.items       := a_items;
    self.object_name := lower(trim(a_object_name));
    
    if a_rollback_type is not null then
      ut_utils.validate_rollback_type(a_rollback_type);
      self.rollback_type := a_rollback_type;
    else
      self.rollback_type := ut_utils.gc_rollback_auto;
    end if;  
    
    return;
  end ut_test_suite;

  member procedure set_suite_setup(self in out nocopy ut_test_suite, a_object_name in varchar2, a_proc_name in varchar2, a_owner_name varchar2 default null) is
  begin
    self.setup := ut_executable(object_name    => trim(a_object_name)
                               ,procedure_name => trim(a_proc_name)
                               ,owner_name     => trim(a_owner_name));
  end;

  member procedure set_suite_teardown(self in out nocopy ut_test_suite, a_object_name in varchar2, a_proc_name in varchar2, a_owner_name varchar2 default null) is
  begin
    self.teardown := ut_executable(object_name    => trim(a_object_name)
                                  ,procedure_name => trim(a_proc_name)
                                  ,owner_name     => trim(a_owner_name));
  end;

  member function is_valid return boolean is
    l_is_valid boolean;
  begin
    l_is_valid := (setup is null or setup.is_valid('suitesetup')) and
                  (teardown is null or teardown.is_valid('suiteteardown'));
  
    return l_is_valid;
  end is_valid;

  overriding member procedure do_execute(self in out nocopy ut_test_suite, a_reporter ut_reporter) is
    l_reporter ut_reporter := a_reporter;
  begin
    l_reporter := do_execute(l_reporter);
  end;

  overriding member function do_execute(self in out nocopy ut_test_suite, a_reporter ut_reporter)
    return ut_reporter is
    l_reporter    ut_reporter := a_reporter;
    l_test_object ut_test_object;
    l_savepoint varchar2(30);
  begin
    l_reporter.before_suite(self);
  
    ut_utils.debug_log('ut_test_suite.execute');

    self.start_time := current_timestamp;
    
    if self.ignore_flag = 1 then
      self.result := ut_utils.tr_ignore;
    elsif self.is_valid() then
      
      if self.rollback_type = ut_utils.gc_rollback_auto then
        l_savepoint := ut_utils.gen_savepoint_name;
        execute immediate 'savepoint ' || l_savepoint;
      end if;
    
      if self.setup is not null then
				l_reporter.before_suite_setup(self);
        self.setup.do_execute;
        l_reporter.after_suite_setup(self);
      end if;
    
      for i in self.items.first .. self.items.last loop
        l_reporter.before_suite_item(a_suite => self,a_item_index => i);
        
        l_test_object := treat(self.items(i) as ut_test_object);
        l_reporter := l_test_object.do_execute(a_reporter => l_reporter);
        self.items(i) := l_test_object;
        
        l_reporter.after_suite_item(a_suite => self,a_item_index => i);
      end loop;
    
      if self.teardown is not null then
        l_reporter.before_suite_teardown(self);
        self.teardown.do_execute;
        l_reporter.after_suite_teardown(self);
      end if;
    
      self.calc_execution_result;
      
      if self.rollback_type = ut_utils.gc_rollback_auto then
        execute immediate 'rollback to ' || l_savepoint;
      end if;
    else
      self.result := ut_utils.tr_error;
    end if;
  
    self.end_time := current_timestamp;
  
    l_reporter.after_suite(self);
    return l_reporter;
  end;

  overriding member procedure do_execute(self in out nocopy ut_test_suite) is
    l_null_reporter ut_reporter := ut_reporter();
  begin
    self.do_execute(l_null_reporter);
  end;

end;
/
