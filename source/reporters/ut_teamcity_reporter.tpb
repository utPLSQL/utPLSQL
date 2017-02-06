create or replace type body ut_teamcity_reporter is

  constructor function ut_teamcity_reporter(a_output ut_output default ut_output_dbms_output()) return self as result is
  begin
    self.name   := $$plsql_unit;
    self.output := a_output;
    return;
  end;

  overriding member procedure before_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_logical_suite) is
  begin
    self.print_text(
      ut_teamcity_reporter_helper.test_suite_started(
        a_suite_name => nvl(replace(trim(a_suite.description), '.'),a_suite.name))
      );
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_logical_suite) is
  begin
    self.print_text(
      ut_teamcity_reporter_helper.test_suite_finished(
        a_suite_name => nvl(replace(trim(a_suite.description), '.'),a_suite.name))
      );
  end;

  overriding member procedure before_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test) is
    l_test_full_name varchar2(4000);
  begin
    
    l_test_full_name := lower(a_test.item.owner_name)||'.'||lower(a_test.item.object_name)||'.'||lower(a_test.item.procedure_name);
    
    self.print_text(ut_teamcity_reporter_helper.test_started(a_test_name => l_test_full_name));
  
  end;

  overriding member procedure after_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test) is
    l_assert           ut_assert_result;
    l_test_full_name   varchar2(4000);
  begin
--    l_test_full_name := self.suite_names_stack(self.suite_names_stack.last) || ':' ||
--                        nvl(replace(a_test.description, '.'), a_test.name);
    l_test_full_name := lower(a_test.item.owner_name)||'.'||lower(a_test.item.object_name)||'.'||lower(a_test.item.procedure_name);                        

    if a_test.result = ut_utils.tr_ignore then
      self.print_text(ut_teamcity_reporter_helper.test_ignored(l_test_full_name));
    else

      if a_test.results is not null and a_test.results.count > 0 then
        for i in 1 .. a_test.results.count loop

          l_assert := a_test.results(i);

          if l_assert.result > ut_utils.tr_success then
            self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name
                                                                   ,a_msg       => l_assert.message
                                                                   ,a_expected  => l_assert.expected_value_string
                                                                   ,a_actual    => l_assert.actual_value_string));
            -- Teamcity supports only a single failure message
            exit;
          end if;

        end loop;
      elsif a_test.result = ut_utils.tr_failure then
        self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name, a_msg => 'Test failed'));
      elsif a_test.result = ut_utils.tr_error then
        self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name, a_msg => 'Error occured'));
      end if;

      self.print_text(ut_teamcity_reporter_helper.test_finished(l_test_full_name, trunc(a_test.execution_time * 1e3)));

    end if;
    
  end;

end;
/
