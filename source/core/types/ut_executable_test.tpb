create or replace noneditionable type body ut_executable_test as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

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
    a_expected_errors in ut_varchar2_rows
  ) is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_expected_errors);
  end do_execute;

  member function do_execute(
    self in out nocopy ut_executable_test, a_item in out nocopy ut_suite_item,
    a_expected_errors in ut_varchar2_rows
  ) return boolean is
    l_failure_message          varchar2(32767);
    l_expected_error_names     ut_varchar2_rows;
    l_expected_error_numbers   ut_varchar2_rows;
    l_all_expected_errors      ut_varchar2_rows;

    procedure build_expected_exceptions(
      a_item                   in out nocopy ut_suite_item,
      a_exception_definitions  in ut_varchar2_rows,
      a_exception_names_list   out ut_varchar2_rows,
      a_exception_numbers_list out ut_varchar2_rows
    ) is
      l_exception_number        integer;
      l_exception_name          varchar2(128);
      function to_exception_number (a_exception_var in varchar2, a_item ut_suite_item) return integer is
        function get_exception_no(a_exception_var in varchar2) return integer is
          l_exc_no integer;
        begin
          execute immediate 'declare l_exception integer; begin :l_exception := '||a_exception_var||'; end;'
            using out l_exc_no;
          return l_exc_no;
        exception
          when others then
              return null;
        end;
        function remap_no_data_found (a_number integer) return integer is
        begin
          return case a_number when 100 then -1403 else a_number end;
        end;
      begin
        return remap_no_data_found(
 coalesce(
                get_exception_no(a_exception_var),
                get_exception_no(a_item.object_owner||'.'||a_exception_var),
                get_exception_no(a_item.object_owner||'.'||a_item.object_name||'.'||a_exception_var)
          )
        );
      end;

      function to_exception_name (a_exception_var in varchar2, a_item ut_suite_item) return varchar2 is
        function verify_name(a_exception_name in varchar2) return varchar2 is
        begin
          --check if it is an existing, named exception
          execute immediate 'begin null; exception when '||a_exception_name||' then null; end;';
          return a_exception_name;
        exception
          when others then
              return null;
        end;
      begin
        return coalesce(
                verify_name(a_exception_var),
                verify_name(a_item.object_owner||'.'||a_exception_var),
                verify_name(a_item.object_owner||'.'||a_item.object_name||'.'||a_exception_var)
        );

      end;

    begin
      a_exception_names_list   := ut_varchar2_rows();
      a_exception_numbers_list := ut_varchar2_rows();
      if a_exception_definitions is not empty then
        for i in 1 .. a_exception_definitions.count loop
          l_exception_number :=
            coalesce(
              to_exception_number(a_exception_definitions(i), a_item),
              to_number(a_exception_definitions(i) default null on conversion error )
          );
          l_exception_name := to_exception_name(a_exception_definitions(i), a_item);

          if l_exception_number is null and l_exception_name is null then
            a_item.put_warning(
              'Invalid parameter value "'||a_exception_definitions(i)||'" for "--%throws" annotation. Parameter ignored.',
              self.procedure_name,
              a_item.line_no
            );
          elsif l_exception_number >= 0 then
            a_item.put_warning(
              'Invalid parameter value "'||a_exception_definitions(i)||'" for "--%throws" annotation. Exception value must be a negative integer. Parameter ignored.',
              self.procedure_name,
              a_item.line_no
              );
          elsif l_exception_number is not null then
            a_exception_numbers_list.extend;
            a_exception_numbers_list(a_exception_numbers_list.last) := l_exception_number;
          elsif l_exception_name is not null then
            a_exception_names_list.extend;
            a_exception_names_list(a_exception_names_list.last) := l_exception_name;
          end if;
        end loop;
      end if;
    end;

    function get_exception_failure_message(a_expected_errors_list ut_varchar2_rows) return varchar is
      l_actual_error_no      integer;
      l_expected_errors      varchar2(4000);
      l_fail_message         varchar2(4000);
    begin
      --Convert the ut_varchar2_list to string to can construct the message
      l_expected_errors := ut_utils.table_to_clob(a_expected_errors_list, ', ');

      if self.error_stack is null then
        l_fail_message := 'Expected one of exceptions ('|| l_expected_errors|| ') but nothing was raised.';
      else
        l_actual_error_no := regexp_substr(self.error_stack, '^[[:alpha:]]{3}(-[0-9]+)', subexpression=>1);
        if not l_actual_error_no member of a_expected_errors_list or l_actual_error_no is null then
          l_fail_message := 'Actual: '||l_actual_error_no||' was expected to ';
          if cardinality(a_expected_errors_list) > 1 then
            l_fail_message := l_fail_message || 'be one of: ('|| l_expected_errors|| ')';
          else
            l_fail_message := l_fail_message || 'equal: '||l_expected_errors;
          end if;
          l_fail_message := substr( l_fail_message||chr(10)||self.error_stack||chr(10)||self.error_backtrace, 1, 4000 );
        end if;
      end if;

      return l_fail_message;
    end;
  begin
    --Create a ut_executable object and call do_execute after that get the data to know the test's execution result
    build_expected_exceptions(a_item, a_expected_errors, l_expected_error_names, l_expected_error_numbers );

    self.do_execute(a_item, l_expected_error_names, l_expected_error_numbers);
    l_all_expected_errors := l_expected_error_names multiset union all l_expected_error_numbers;
    if l_all_expected_errors is not empty and self.ignored_exception_detected = 0 then
      l_failure_message := get_exception_failure_message( l_all_expected_errors);

      if l_failure_message is not null then
        ut_expectation_processor.add_expectation_result(
          ut_expectation_result(ut_utils.gc_failure, null, l_failure_message, false)
        );
      end if;
      self.error_stack := null;
      self.error_backtrace := null;
    end if;

    return (self.error_stack||self.error_backtrace) is null;
  end;
end;
/
