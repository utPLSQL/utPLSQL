create or replace type body ut_test is

  constructor function ut_test(a_object_name varchar2, a_test_procedure varchar2, a_test_name in varchar2 default null, a_owner_name varchar2 default null, a_setup_procedure varchar2 default null, a_teardown_procedure varchar2 default null, a_rollback_type integer default null)
    return self as result is
  begin
    self.name        := a_test_name;
    self.object_type := 1;
    self.object_name := lower(trim(a_test_procedure));
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

    if a_rollback_type is not null then
      ut_utils.validate_rollback_type(a_rollback_type);
      self.rollback_type := a_rollback_type;
    else
      self.rollback_type := ut_utils.gc_rollback_auto;
    end if;
    return;
  end ut_test;

  member function is_valid return boolean is
  begin
    return test.is_valid('test') and(setup is null or setup.is_valid('setup')) and(teardown is null or
                                                                                   teardown.is_valid('teardown'));
  end is_valid;

  overriding member procedure execute(self in out nocopy ut_test, a_reporter ut_reporter) is
    l_reporter ut_reporter := a_reporter;
  begin
    l_reporter := execute(l_reporter);
  end;
  overriding member function execute(self in out nocopy ut_test, a_reporter ut_reporter) return ut_reporter is
    l_reporter ut_reporter := a_reporter;
    l_savepoint varchar2(30);
  begin
    l_reporter.before_test(self);

    if self.rollback_type = ut_utils.gc_rollback_auto then
      l_savepoint := ut_utils.gen_savepoint_name;
      execute immediate 'savepoint ' || l_savepoint;
    end if;

    ut_utils.debug_log('ut_test.execute');

    self.start_time := current_timestamp;
    
    if nvl(self.ignore_flag,0) != 1 then
      begin

        if self.is_valid() then

          if self.setup is not null then
            l_reporter.before_test_setup(self);
            self.setup.execute;
            l_reporter.after_test_setup(self);
          end if;

          l_reporter.before_test_execute(self);
          begin
            self.test.execute;
          exception
            when others then
              -- dbms_utility.format_error_backtrace is 10g or later
              -- utl_call_stack package may be better but it's 12c but still need to investigate
              -- article with details: http://www.oracle.com/technetwork/issue-archive/2014/14-jan/o14plsql-2045346.html
              ut_utils.debug_log('testmethod failed-' || sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);

              ut_assert_processor.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
          end;
          l_reporter.after_test_execute(self);

          if self.teardown is not null then
            l_reporter.before_test_teardown(self);
            self.teardown.execute;
            l_reporter.after_test_teardown(self);
          end if;

        end if;

      exception
        when others then
          if sqlcode = -04068 then
            --raise on ORA-04068: existing state of packages has been discarded to avoid unrecoverable session exception
            raise;
          end if;
          ut_utils.debug_log('ut_test.execute failed-' || sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
          -- most likely occured in setup or teardown if here.
          ut_assert_processor.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_stack);
          ut_assert_processor.report_error(sqlerrm(sqlcode) || ' ' || dbms_utility.format_error_backtrace);
      end;

      if self.rollback_type = ut_utils.gc_rollback_auto then
        execute immediate 'rollback to ' || l_savepoint;
      end if;

      self.end_time := current_timestamp;

      l_reporter.before_asserts_process(self);
      self.items := ut_assert_processor.get_asserts_results();

      self.calc_execution_result;

      for i in 1 .. self.items.count loop
        l_reporter.on_assert_process(treat(self.items(i) as ut_assert_result));
      end loop;

      l_reporter.after_asserts_process(self);
    else
      self.end_time := current_timestamp;
      self.result := ut_utils.tr_ignore;
    end if;
  
    l_reporter.after_test(self);

    return l_reporter;
  end;

  overriding member procedure execute(self in out nocopy ut_test) is
    l_null_reporter ut_reporter := ut_reporter();
  begin
    self.execute(l_null_reporter);
  end execute;

end;
/
