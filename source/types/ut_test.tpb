create or replace type body ut_test is

  constructor function ut_test(a_object_name varchar2, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null)
    return self as result is
  begin
    self.name        := a_test_name;
    self.call_params := ut_test_call_params(object_name        => trim(a_object_name)
                                           ,test_procedure     => trim(a_test_procedure)
                                           ,owner_name         => trim(a_owner_name)
                                           ,setup_procedure    => trim(a_setup_procedure)
                                           ,teardown_procedure => trim(a_teardown_procedure));
    return;
  end ut_test;

  member function is_valid(self in ut_test) return boolean is
  begin
    if call_params.test_procedure is null then
      return false;
    end if;
  
    if not ut_metadata.resolvable(call_params.owner_name, call_params.object_name, call_params.test_procedure) then
      return false;
    end if;
  
    if call_params.setup_procedure is not null and
       not ut_metadata.resolvable(call_params.owner_name, call_params.object_name, call_params.setup_procedure) then
      return false;
    end if;
  
    if call_params.teardown_procedure is not null and
       not ut_metadata.resolvable(call_params.owner_name, call_params.object_name, call_params.teardown_procedure) then
      return false;
    end if;
  
    return true;
  end is_valid;

  overriding member procedure execute(self in out nocopy ut_test, a_reporter in out nocopy ut_suite_reporter) is
    params_valid boolean;  
  begin
    if a_reporter is not null then
      a_reporter.begin_test(a_test_name => self.name, a_test_call_params => self.call_params);
    end if;
  
    begin
      $if $$ut_trace $then
      dbms_output.put_line('ut_test.execute');
      $end
    
      self.execution_result := ut_execution_result();
    
      self.call_params.validate_params(params_valid);
			
      if params_valid then
        self.call_params.setup;
        begin
          self.call_params.run_test;
        exception
          when others then
            -- dbms_utility.format_error_backtrace is 10g or later
            -- utl_call_stack package may be better but it's 12c but still need to investigate
            -- article with details: http://www.oracle.com/technetwork/issue-archive/2014/14-jan/o14plsql-2045346.html
            $if $$ut_trace $then
            dbms_output.put_line('testmethod failed-' || sqlerrm(sqlcode) || ' ' ||
                                 dbms_utility.format_error_backtrace);
            $end
            ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
        end;
        self.call_params.teardown;
      end if;
    
      self.execution_result.end_time := current_timestamp;
    
      ut_assert.process_asserts(self.assert_results, self.execution_result.result);
    
    exception
      when others then
        $if $$ut_trace $then
        dbms_output.put_line('ut_test.execute failed-' || sqlerrm(sqlcode) || ' ' ||
                             dbms_utility.format_error_backtrace);
        $end
        -- most likely occured in setup or teardown if here.
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_stack);
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
        ut_assert.process_asserts(self.assert_results, self.execution_result.result);
    end;
  
    if a_reporter is not null then
      a_reporter.end_test(a_test_name        => self.name
                         ,a_test_call_params => self.call_params
                         ,a_execution_result => self.execution_result
                         ,a_assert_list      => self.assert_results);
    end if;
  end;

  overriding member procedure execute(self in out nocopy ut_test) is
	  v_null_reporter ut_suite_reporter;
  begin
    self.execute(v_null_reporter);
  end execute;

end;
/
