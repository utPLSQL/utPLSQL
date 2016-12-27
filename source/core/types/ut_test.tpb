create or replace type body ut_test is

  constructor function ut_test(self in out nocopy ut_test,a_object_name varchar2,a_object_path varchar2 default null, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null, a_rollback_type integer default null)
    return self as result is
  begin
    
    self.init(a_desc_name     => a_test_name
             ,a_object_name   => a_test_procedure
             ,a_object_type   => 1
             ,a_object_path   => a_object_path
             ,a_rollback_type => a_rollback_type);

    self.object_type := 1;
    self.test        := ut_executable(object_name    => trim(a_object_name)
                                     ,procedure_name => trim(a_test_procedure)
                                     ,owner_name     => trim(a_owner_name));
  
    if a_setup_procedure is not null then
      self.setup := ut_executable(object_name    => trim(a_object_name)
                                 ,procedure_name => trim(a_setup_procedure)
                                 ,owner_name     => trim(a_owner_name));
    end if;
  
    if a_teardown_procedure is not null then
      self.teardown := ut_executable(object_name    => trim(a_object_name)
                                    ,procedure_name => trim(a_teardown_procedure)
                                    ,owner_name     => trim(a_owner_name));
    end if;

    return;
  end ut_test;

  member function is_valid return boolean is
  begin
    return test.is_valid('test') and(setup is null or setup.is_valid('setup')) and(teardown is null or
                                                                                   teardown.is_valid('teardown'));
  end is_valid;

  overriding member procedure do_execute(self in out nocopy ut_test, a_reporter in out nocopy ut_reporter, a_parent_err_msg varchar2 default null) is
    l_savepoint       varchar2(30);
    l_errors_raised   boolean := false;
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
    a_reporter.before_test(self);

    if self.rollback_type = ut_utils.gc_rollback_auto then
      l_savepoint := ut_utils.gen_savepoint_name;
      execute immediate 'savepoint ' || l_savepoint;
    end if;

    ut_utils.debug_log('ut_test.execute');

    self.start_time := current_timestamp;
    
    if self.get_ignore_flag() = false then
      if self.is_valid() then

        if self.setup is not null and a_parent_err_msg is null then
          a_reporter.before_test_setup(self);
          self.setup.do_execute(l_error_stack, l_error_backtrace);
          l_errors_raised := process_errors_from_call( l_error_stack, l_error_backtrace );
          a_reporter.after_test_setup(self);
        end if;

        if not l_errors_raised then
          a_reporter.before_test_execute(self);
          if a_parent_err_msg is null then
            self.test.do_execute(l_error_stack, l_error_backtrace);
            l_errors_raised := process_errors_from_call( l_error_stack, l_error_backtrace );
          else
            ut_assert_processor.report_error(a_parent_err_msg);
          end if;
          a_reporter.after_test_execute(self);

          if self.teardown is not null and a_parent_err_msg is null then
            a_reporter.before_test_teardown(self);
            self.teardown.do_execute(l_error_stack, l_error_backtrace);
            l_errors_raised := process_errors_from_call( l_error_stack, l_error_backtrace );
            a_reporter.after_test_teardown(self);
          end if;

        end if;

      end if;

      if self.rollback_type = ut_utils.gc_rollback_auto then
        execute immediate 'rollback to ' || l_savepoint;
      end if;

      self.end_time := current_timestamp;

      a_reporter.before_asserts_process(self);
      self.items := ut_assert_processor.get_asserts_results();

      self.calc_execution_result;

      for i in 1 .. self.items.count loop
        a_reporter.on_assert_process(treat(self.items(i) as ut_assert_result));
      end loop;

      a_reporter.after_asserts_process(self);
    else
      self.end_time := current_timestamp;
      self.result := ut_utils.tr_ignore;
    end if;
  
    a_reporter.after_test(self);
  end;

end;
/
