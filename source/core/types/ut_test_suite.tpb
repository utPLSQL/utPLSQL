create or replace type body ut_test_suite is

  constructor function ut_test_suite(self in out nocopy ut_test_suite, a_suite_name varchar2, a_object_name varchar2, a_object_path varchar2 default null, a_items ut_objects_list default ut_objects_list(), a_rollback_type number default null)
    return self as result is
  begin
  
    self.init(a_desc_name     => a_suite_name
             ,a_object_name   => a_object_name
             ,a_object_type   => 2
             ,a_object_path   => a_object_path
             ,a_rollback_type => a_rollback_type);
  
    self.items := a_items;
  
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

  overriding member procedure do_execute(self in out nocopy ut_test_suite, a_reporter in out nocopy ut_reporter, a_parent_err_msg varchar2 default null) is
    l_test_object     ut_test_object;
    l_savepoint       varchar2(30);
    l_errors_raised   boolean;
    l_errors_stack_trace varchar2(32767);
    l_error_stack     varchar2(32767);
    l_error_backtrace varchar2(32767);
    function process_errors_from_call( a_error_stack varchar2, a_error_backtrace varchar2) return boolean is
      l_errors_stack_trace varchar2(32767) := rtrim(a_error_stack||a_error_backtrace, chr(10));
    begin
      if l_errors_stack_trace is not null then
        ut_utils.debug_log('test method failed- ' ||l_errors_stack_trace );
        ut_assert_processor.report_error( l_errors_stack_trace );
        return true;
      else
        return false;
      end if;
    end;
  begin
    a_reporter.before_suite(self);
  
    ut_utils.debug_log('ut_test_suite.execute');
  
    self.start_time := current_timestamp;
  
    if self.ignore_flag = 1 then
      self.result := ut_utils.tr_ignore;
    else
      if self.rollback_type = ut_utils.gc_rollback_auto then
        l_savepoint := ut_utils.gen_savepoint_name;
        execute immediate 'savepoint ' || l_savepoint;
      end if;
    
      if self.setup is not null and a_parent_err_msg is null then
        a_reporter.before_suite_setup(self);
        self.setup.do_execute(l_error_stack, l_error_backtrace);
        if l_error_stack is not null then
          l_errors_stack_trace := 'Suite '||self.object_path||' setup failed.'||chr(10)|| rtrim(l_error_stack||l_error_backtrace, chr(10));
        end if;
        a_reporter.after_suite_setup(self);
      end if;
    
      for i in self.items.first .. self.items.last loop
        a_reporter.before_suite_item(a_suite => self, a_item_index => i);
        
        l_test_object := treat(self.items(i) as ut_test_object);
        l_test_object.do_execute(a_reporter => a_reporter, a_parent_err_msg => nvl(l_errors_stack_trace, a_parent_err_msg));
        self.items(i) := l_test_object;
        
        a_reporter.after_suite_item(a_suite => self, a_item_index => i);
      end loop;
      
      if self.teardown is not null and a_parent_err_msg is null then
        a_reporter.before_suite_teardown(self);
        self.teardown.do_execute();
        a_reporter.after_suite_teardown(self);
      end if;
    
      self.calc_execution_result;
    
      if self.rollback_type = ut_utils.gc_rollback_auto then
        execute immediate 'rollback to ' || l_savepoint;
      end if;
    end if;
  
    self.end_time := current_timestamp;
  
    a_reporter.after_suite(self);
  end;

end;
/
