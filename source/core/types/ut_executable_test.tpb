create or replace type body ut_executable_test as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  constructor function ut_executable_test(
    self in out nocopy ut_executable_test, a_owner varchar2, a_package varchar2,
    a_procedure_name varchar2, a_executable_type varchar2
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.executable_type := a_executable_type;
    self.owner_name := a_owner;
    self.object_name := a_package;
    self.procedure_name := a_procedure_name;
    return;
  end;

  member procedure do_execute(
    self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item,
    a_expected_error_codes in ut_integer_list
  ) is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_expected_error_codes);
  end do_execute;

  member function do_execute(
    self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item,
    a_expected_error_codes in ut_integer_list
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
    self.do_execute(a_item);

    if a_expected_error_codes is not null and a_expected_error_codes is not empty then
      l_expected_except_message := failed_expec_errnum_message(a_expected_error_codes);

      if l_expected_except_message is not null then
        ut_expectation_processor.add_expectation_result(
          ut_expectation_result(ut_utils.gc_failure, null, l_expected_except_message, false)
        );
      end if;
      self.error_stack := null;
      self.error_backtrace := null;
    end if;

    return (self.error_stack||self.error_backtrace) is null;
  end;
end;
/
