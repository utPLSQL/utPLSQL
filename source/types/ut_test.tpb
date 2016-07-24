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
    return call_params.test_procedure is not null and ut_metadata.resolvable(call_params.owner_name, call_params.object_name, call_params.test_procedure) and (call_params.setup_procedure is null OR ut_metadata.resolvable(call_params.owner_name, call_params.object_name, call_params.setup_procedure)) and (call_params.teardown_procedure is null OR ut_metadata.resolvable(call_params.owner_name, call_params.object_name, call_params.teardown_procedure));
  end is_valid;

  overriding member procedure execute(self in out nocopy ut_test, a_reporter ut_suite_reporter) is
    reporter ut_suite_reporter := a_reporter;
  begin
    reporter := execute(reporter);
  end;
  overriding member function execute(self in out nocopy ut_test, a_reporter ut_suite_reporter) return ut_suite_reporter is
    reporter ut_suite_reporter := a_reporter;
  begin
    if reporter is not null then
      reporter.begin_test(a_test_name => self.name, a_test_call_params => self.call_params);
    end if;
  
    begin
      $if $$ut_trace $then
      dbms_output.put_line('ut_test.execute');
      $end
    
      self.execution_result := ut_execution_result();
			
      if self.call_params.validate_params() then
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
        if sqlcode = -04068 then
          --raise on ORA-04068: existing state of packages has been discarded to avoid unrecoverable session exception
          raise;
        end if;
        $if $$ut_trace $then
        dbms_output.put_line('ut_test.execute failed-' || sqlerrm(sqlcode) || ' ' ||
                             dbms_utility.format_error_backtrace);
        $end
        -- most likely occured in setup or teardown if here.
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_stack);
        ut_assert.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
        self.execution_result.end_time := current_timestamp;
        ut_assert.process_asserts(self.assert_results, self.execution_result.result);
    end;
  
    if reporter is not null then
      reporter.end_test(a_test_name        => self.name
                       ,a_test_call_params => self.call_params
                       ,a_execution_result => self.execution_result
                       ,a_assert_list      => self.assert_results);
    end if;
    return reporter;
  end;

  overriding member procedure execute(self in out nocopy ut_test) is
	  v_null_reporter ut_suite_reporter;
  begin
    self.execute(v_null_reporter);
  end execute;

end;
/
