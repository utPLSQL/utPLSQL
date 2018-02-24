create or replace type body ut_executable_test as
  constructor function ut_executable_test(
    self in out nocopy ut_executable_test, a_context ut_suite_item,
    a_procedure_name varchar2, a_associated_event_name varchar2
  ) return self as result is
  begin
    self.associated_event_name := a_associated_event_name;
    self.owner_name := a_context.object_owner;
    self.object_name := a_context.object_name;
    self.procedure_name := a_procedure_name;
    return;
  end;

  member procedure do_execute(
    self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item, 
    a_listener in out nocopy ut_event_listener_base, a_expected_error_codes in ut_integer_list
  ) is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_listener, a_expected_error_codes);
  end do_execute;

  member function do_execute(
    self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item, 
    a_listener in out nocopy ut_event_listener_base, a_expected_error_codes in ut_integer_list
  ) return boolean is
    l_expected_except_message  varchar2(4000);

    function failed_expec_errnum_message(a_expected_error_codes in ut_integer_list) return varchar is
      l_actual_error_no      integer;
      l_expected_error_codes varchar2(4000);
      l_fail_message         varchar2(4000);
    begin
      --Convert the ut_varchar2_list to string to can construct the message
      l_expected_error_codes := ut_utils.table_to_clob(a_expected_error_codes, ', ');

      if self.error_stack is null then
        l_fail_message := 'Expected one of exceptions ('||l_expected_error_codes||') but nothing was raised.';
      else
        l_actual_error_no := regexp_substr(self.error_stack, '^[a-zA-Z]{3}(-[0-9]+)', subexpression=>1);
        if not l_actual_error_no member of a_expected_error_codes then
          l_fail_message := 'Actual: '||l_actual_error_no||' was expected to ';
          if cardinality(a_expected_error_codes) > 1 then
            l_fail_message := l_fail_message || 'be one of: ('||l_expected_error_codes||')';
          else
            l_fail_message := l_fail_message || 'equal: '||l_expected_error_codes;
          end if;
          l_fail_message := substr( l_fail_message||chr(10)||self.error_stack||chr(10)||self.error_backtrace, 1, 4000 );
        end if;
      end if;

      return l_fail_message;
    end;
  begin
    --Create a ut_executable object and call do_execute after that get the data to know the test's execution result
    self.do_execute(a_item, a_listener);

    if a_expected_error_codes is not null and a_expected_error_codes is not empty then
      l_expected_except_message := failed_expec_errnum_message(a_expected_error_codes);

      if l_expected_except_message is not null then
        ut_expectation_processor.add_expectation_result(
          ut_expectation_result(ut_utils.tr_failure, null, l_expected_except_message, false)
        );
      end if;
      self.error_stack := null;
      self.error_backtrace := null;
    end if;

    return (self.error_stack||self.error_backtrace) is null;
  end;
end;
/
