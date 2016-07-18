create or replace type body ut_single_test is

  constructor function ut_single_test(a_object_name varchar2, a_test_procedure varchar2, a_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null)
    return self as result is
  begin
    self.name        := a_name;
    self.call_params := ut_test_call_params(object_name        => trim(a_object_name)
                                           ,test_procedure     => trim(a_test_procedure)
                                           ,owner_name         => coalesce(trim(a_owner_name)
                                                                          ,sys_context('userenv', 'current_schema'))
                                           ,setup_procedure    => trim(a_setup_procedure)
                                           ,teardown_procedure => trim(a_teardown_procedure));
    return;
  end ut_single_test;

  member function is_valid(self in ut_single_test) return boolean is
  begin
    if call_params.test_procedure is null then
      return false;
    end if;
  
    if not ut_metadata.do_resolve(call_params.owner_name, call_params.object_name, call_params.test_procedure) then
      return false;
    end if;
  
    if call_params.setup_procedure is not null and
       not ut_metadata.do_resolve(call_params.owner_name, call_params.object_name, call_params.setup_procedure) then
      return false;
    end if;
  
    if call_params.teardown_procedure is not null and
       not ut_metadata.do_resolve(call_params.owner_name, call_params.object_name, call_params.teardown_procedure) then
      return false;
    end if;
  
    return true;
  end is_valid;

  member function setup_stmt(self in ut_single_test) return varchar2 is
  begin
    if trim(call_params.setup_procedure) is null or trim(call_params.object_name) is null then
      return null;
    end if;
  
    if trim(call_params.owner_name) is not null then
      return trim(call_params.owner_name) || '.' || call_params.object_name || '.' || call_params.setup_procedure;
    else
      return call_params.object_name || '.' || call_params.setup_procedure;
    end if;
  end setup_stmt;

  member function test_stmt(self in ut_single_test) return varchar2 is
  begin
    if trim(call_params.test_procedure) is null or trim(call_params.object_name) is null then
      return null;
    end if;
  
    if trim(call_params.owner_name) is not null then
      return trim(call_params.owner_name) || '.' || call_params.object_name || '.' || call_params.test_procedure;
    else
      return call_params.object_name || '.' || call_params.test_procedure;
    end if;
  end test_stmt;

  member function teardown_stmt(self in ut_single_test) return varchar2 is
  begin
    if trim(call_params.teardown_procedure) is null or trim(call_params.object_name) is null then
      return null;
    end if;
  
    if trim(call_params.owner_name) is not null then
      return trim(call_params.owner_name) || '.' || call_params.object_name || '.' || call_params.teardown_procedure;
    else
      return call_params.object_name || '.' || call_params.teardown_procedure;
    end if;
  end teardown_stmt;

  overriding member procedure execute(self in out nocopy ut_single_test, a_reporter in ut_suite_reporter) is
    params_valid boolean;  
  begin
    if a_reporter is not null then
      a_reporter.begin_test(a_test_name => self.name, a_test_call_params => self.call_params);
    end if;
  
    begin
      $if $$ut_trace $then
      dbms_output.put_line('ut_single_test.execute');
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
        dbms_output.put_line('ut_single_test.execute failed-' || sqlerrm(sqlcode) || ' ' ||
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

  overriding member procedure execute(self in out nocopy ut_single_test) is
  begin
    self.execute(cast(null as ut_suite_reporter));
  end execute;

end;
/
