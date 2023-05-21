create or replace type body ut_executable_test as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
    a_expected_error_codes in ut_varchar2_rows
  ) is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_expected_error_codes);
  end do_execute;

  member function do_execute(
    self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item,
    a_expected_error_codes in ut_varchar2_rows
  ) return boolean is
    l_expected_except_message  varchar2(4000);
    l_expected_error_numbers   ut_integer_list;

    function build_exception_numbers_list(
      a_item                 in out nocopy ut_suite_item,
      a_expected_error_codes in ut_varchar2_rows
    ) return ut_integer_list is
      l_exception_number        integer;
      l_exception_number_list   ut_integer_list := ut_integer_list();
      c_regexp_for_exception_no constant varchar2(30) := '^-?[[:digit:]]{1,5}$';

      c_integer_exception       constant varchar2(1) := 'I';
      c_named_exception         constant varchar2(1) := 'N';

      function is_valid_qualified_name (a_name varchar2) return boolean is
        l_name varchar2(500);
      begin
        l_name := dbms_assert.qualified_sql_name(a_name);
        return true;
      exception when others then
        return false;
      end;

      function check_exception_type(a_exception_name in varchar2) return varchar2 is
        l_exception_type varchar2(50);
      begin
        --check if it is a predefined exception
        begin
          execute immediate 'begin null; exception when '||a_exception_name||' then null; end;';
          l_exception_type := c_named_exception;
        exception
          when others then
            if dbms_utility.format_error_stack() like '%PLS-00485%' then
              declare
                e_invalid_number exception;
                pragma exception_init ( e_invalid_number, -6502 );
              begin
                execute immediate 'declare x integer := '||a_exception_name||'; begin null; end;';
                l_exception_type := c_integer_exception;
              exception
                when others then
                  null;
              end;
              end if;
        end;
        return l_exception_type;
      end;

      function get_exception_number (a_exception_var in varchar2) return integer is
        l_exc_no   integer;
        l_exc_type varchar2(50);
        function remap_no_data_found (a_number integer) return integer is
        begin
          return case a_number when 100 then -1403 else a_number end;
        end;
      begin
        l_exc_type := check_exception_type(a_exception_var);

        execute immediate
          case l_exc_type
          when c_integer_exception then
            'declare l_exception number; begin :l_exception := '||a_exception_var||'; end;'
          when c_named_exception then
            'begin raise '||a_exception_var||'; exception when others then :l_exception := sqlcode; end;'
          else
            'begin :l_exception := null; end;'
          end
          using out l_exc_no;

        return remap_no_data_found(l_exc_no);
      end;

    begin
      if a_expected_error_codes is not empty then
        for i in 1 .. a_expected_error_codes.count loop
          /**
          * Check if its a valid qualified name and if so try to resolve name to an exception number
          */
          if is_valid_qualified_name(a_expected_error_codes(i)) then
            l_exception_number := get_exception_number(a_expected_error_codes(i));
          elsif regexp_like(a_expected_error_codes(i), c_regexp_for_exception_no) then
            l_exception_number := a_expected_error_codes(i);
          end if;

          if l_exception_number is null then
            a_item.put_warning(
              'Invalid parameter value "'||a_expected_error_codes(i)||'" for "--%throws" annotation. Parameter ignored.',
              self.procedure_name,
              a_item.line_no
            );
          elsif l_exception_number >= 0 then
            a_item.put_warning(
              'Invalid parameter value "'||a_expected_error_codes(i)||'" for "--%throws" annotation. Exception value must be a negative integer. Parameter ignored.',
              self.procedure_name,
              a_item.line_no
              );
          else
            l_exception_number_list.extend;
            l_exception_number_list(l_exception_number_list.last) := l_exception_number;
          end if;
          l_exception_number := null;
        end loop;
      end if;

      return l_exception_number_list;
    end;
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
        l_actual_error_no := regexp_substr(self.error_stack, '^[[:alpha:]]{3}(-[0-9]+)', subexpression=>1);
        if not l_actual_error_no member of a_expected_error_codes or l_actual_error_no is null then
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
    l_expected_error_numbers := build_exception_numbers_list(a_item, a_expected_error_codes);
    if l_expected_error_numbers is not null and l_expected_error_numbers is not empty then
      l_expected_except_message := failed_expec_errnum_message( l_expected_error_numbers );

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
