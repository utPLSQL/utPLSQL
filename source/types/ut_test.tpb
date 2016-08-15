create or replace type body ut_test is

  constructor function ut_test(a_object_name varchar2, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null)
    return self as result is
  begin
    self.name        := a_test_name;
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

  member function is_valid(self in ut_test) return boolean is
  begin
    return test.is_valid('test') and (setup is null or setup.is_valid('setup')) and
                  (teardown is null or teardown.is_valid('teardown'));
  end is_valid;

  overriding member procedure execute(self in out nocopy ut_test, a_reporter ut_suite_reporter) is
    l_reporter ut_suite_reporter := a_reporter;
  begin
    l_reporter := execute(l_reporter);
  end;
  overriding member function execute(self in out nocopy ut_test, a_reporter ut_suite_reporter) return ut_suite_reporter is
    l_reporter ut_suite_reporter := a_reporter;
  begin
    if l_reporter is not null then
      l_reporter.begin_test(self);
    end if;
  
    begin
      ut_utils.debug_log('ut_test.execute');
    
      self.start_time := current_timestamp;
    
      if self.is_valid() then
        if self.setup is not null then
          self.setup.execute;
        end if;
      
        begin
          self.test.execute;
        exception
          when others then
            -- dbms_utility.format_error_backtrace is 10g or later
            -- utl_call_stack package may be better but it's 12c but still need to investigate
            -- article with details: http://www.oracle.com/technetwork/issue-archive/2014/14-jan/o14plsql-2045346.html
            ut_utils.debug_log('testmethod failed-' || sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);

            ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
        end;
				
        if self.teardown is not null then
          self.teardown.execute;
        end if;
      end if;
    
      self.end_time := current_timestamp;
    
      ut_assert.process_asserts(self.items);
    
    exception
      when others then
        if sqlcode = -04068 then
          --raise on ORA-04068: existing state of packages has been discarded to avoid unrecoverable session exception
          raise;
        end if;
        ut_utils.debug_log('ut_test.execute failed-' || sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
        -- most likely occured in setup or teardown if here.
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_stack);
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
        self.end_time := current_timestamp;
        ut_assert.process_asserts(self.items);
    end;
  
    self.calc_execution_result;
  
    if l_reporter is not null then
      for i in 1 .. self.items.count loop
        l_reporter.on_assert(treat(self.items(i) as ut_assert_result));
      end loop;
      l_reporter.end_test(self);
    end if;
  
    return l_reporter;
  end;

  overriding member procedure execute(self in out nocopy ut_test) is
    l_null_reporter ut_suite_reporter;
  begin
    self.execute(l_null_reporter);
  end execute;

end;
/
