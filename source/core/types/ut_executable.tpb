create or replace noneditionable type body ut_executable is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  constructor function ut_executable(
    self in out nocopy ut_executable, a_owner varchar2, a_package varchar2,
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

  member function form_name(a_skip_current_user_schema boolean := false) return varchar2 is
    l_owner_name varchar2(250) := owner_name;
  begin
    if a_skip_current_user_schema and sys_context('userenv', 'current_schema') = owner_name then
      l_owner_name := null;
    end if;
    return ut_metadata.form_name(l_owner_name, object_name, procedure_name);
  end;

  member procedure do_execute(
    self in out nocopy ut_executable,
    a_item in out nocopy ut_suite_item,
    a_ignored_exception_names in ut_varchar2_rows := null,
    a_ignored_exception_numbers in ut_varchar2_rows :=null)
  is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_ignored_exception_names, a_ignored_exception_numbers);
  end do_execute;

  member function do_execute(
    self in out nocopy ut_executable,
    a_item in out nocopy ut_suite_item,
    a_ignored_exception_names in ut_varchar2_rows := null,
    a_ignored_exception_numbers in ut_varchar2_rows :=null)
  return boolean is
    l_statement                   varchar2(32767);
    l_call                        varchar2(32767);
    l_values                      ut_anydata_list;
    l_json                        clob;
    l_call_error                  varchar2(32767);
    l_parse_error                 varchar2(32767);
    l_status                      number;
    l_cursor_number               number;
    l_completed_without_errors    boolean := true;
    l_failed_with_invalid_pck     boolean := true;
    l_start_transaction_id        varchar2(250);
    l_end_transaction_id          varchar2(250);

    /*
      Unpacks the argument values of a --%testcasesource test case, bound as :ut_values.
      Object types and collections need a variable of their type; other values are read by the call itself.
    */
    function get_test_case_call(a_values ut_anydata_list, a_call varchar2) return varchar2 is
      l_declarations varchar2(32767);
      l_unpacking    varchar2(32767);
      l_type         anytype;
      l_typecode     pls_integer;
    begin
      for i in 1 .. a_values.count loop
        -- the type code, as gettypename raises no_data_found for an NCLOB
        l_typecode := a_values(i).gettype(l_type);
        if l_typecode in (dbms_types.typecode_object, dbms_types.typecode_namedcollection, dbms_types.typecode_varray, dbms_types.typecode_table) then
          l_declarations := l_declarations ||
            '      l_ut_value_' || i || ' "' || replace(a_values(i).gettypename(), '.', '"."') || '";' || chr(10);
          l_unpacking := l_unpacking ||
            '      l_ut_rc := l_ut_values(' || i || ').' ||
            case when l_typecode = dbms_types.typecode_object then 'getobject' else 'getcollection' end ||
            '(l_ut_value_' || i || ');' || chr(10);
        end if;
      end loop;
      return
        'declare' || chr(10) ||
        '      l_ut_values ' || ut_utils.ut_owner || '.ut_anydata_list := :ut_values;' || chr(10) ||
        '      l_ut_rc     pls_integer;' || chr(10) ||
        l_declarations ||
        '    begin' || chr(10) ||
        l_unpacking ||
        '      ' || a_call || chr(10) ||
        '    end;';
    end;

    function is_defined return boolean is
      l_result boolean := false;
      l_message_part varchar2(4000) := 'Call params for ' || self.executable_type || ' are not valid: ';
    begin

      if self.object_name is null then
        self.error_stack := l_message_part || 'package is not defined';
      elsif self.procedure_name is null then
        self.error_stack := l_message_part || 'procedure is not defined';
      else
        l_result := true;
      end if;

      return l_result;
    end is_defined;

    function is_invalid return boolean is
      l_result boolean := true;
      l_message_part varchar2(4000) := 'Call params for ' || self.executable_type || ' are not valid: ';
    begin

      if not ut_metadata.package_valid(self.owner_name, self.object_name) then
        self.error_stack := l_message_part || 'package '||upper(self.owner_name||'.'||self.object_name)||' does not exist or is invalid.';
      elsif not ut_metadata.procedure_exists(upper(self.owner_name), upper(self.object_name), upper(self.procedure_name)) then
        self.error_stack := l_message_part || 'procedure '||upper(self.owner_name || '.' || self.object_name || '.' ||self.procedure_name)||' does not exist.';
      else
        l_result := false;
      end if;

      return l_result;
    end is_invalid;

    procedure save_dbms_output is
      l_status number;
      l_line varchar2(32767);
    begin

      dbms_output.get_line(line => l_line, status => l_status);
      if l_status != 1 then
        dbms_lob.createtemporary(self.serveroutput, true, dur => dbms_lob.session);
      end if;
      while l_status != 1 loop
        if l_line is not null then
          ut_utils.append_to_clob(self.serveroutput, l_line||chr(10));
        end if;
        dbms_output.get_line(line => l_line, status => l_status);
      end loop;
    end save_dbms_output;
  begin
    l_start_transaction_id := dbms_transaction.local_transaction_id(true);

    --listener - before call to executable
    ut_event_manager.trigger_event('before_'||self.executable_type, self);

    l_completed_without_errors := is_defined();
    if l_completed_without_errors then
      begin
        if self.call_source is not null then
          l_json := ut_test_case_values.get_json(a_item.path);
          if l_json is null then
            l_call := self.form_name( a_skip_current_user_schema => true ) || '(' || self.call_arguments || ');';
            -- without its values (e.g. package state was reset) the test case errors when it reads them, instead of breaking the run
            l_values := coalesce(ut_test_case_values.get_values(a_item.path), ut_anydata_list());
            l_call := get_test_case_call(l_values, l_call);
          end if;
        elsif self.call_arguments is not null then
          -- the arguments of a --%testcase are JSON
          l_json := self.call_arguments;
        else
          l_call := self.form_name( a_skip_current_user_schema => true ) || ';';
        end if;
        if l_json is not null then
          l_call := ut_test_case_json.get_call(
            self.owner_name, self.object_name, self.procedure_name, self.form_name( a_skip_current_user_schema => true ), l_json
          );
        end if;
      exception
        when others then
          -- JSON values that don't fit the parameters are an error of this test case, not of the run
          l_call_error := dbms_utility.format_error_stack;
          l_call := 'null;';
      end;
      l_statement :=
      'declare' || chr(10) ||
      '  l_error_stack                varchar2(32767);' || chr(10) ||
      '  l_error_backtrace            varchar2(32767);' || chr(10) ||
      '  l_ignored_exception_detected integer := 0;' || chr(10) ||
      'begin' || chr(10) ||
      '  begin' || chr(10) ||
      '    ' || l_call || chr(10) ||
      '  exception' || chr(10) ||
              case when a_ignored_exception_names is not empty then
      '    when ' || ut_utils.table_to_clob( a_ignored_exception_names, ' or ' ) || ' then ' || chr(10) ||
      '      l_ignored_exception_detected := 1;'
             end ||
      '    when others then ' || chr(10) ||
            case when a_ignored_exception_numbers is not empty then
      '      if sqlcode in (' || ut_utils.table_to_clob( a_ignored_exception_numbers, ', ' ) || ') then ' || chr(10) ||
      '        l_ignored_exception_detected := 1; ' || chr(10) ||
      '      else ' || chr(10) ||
      '        l_error_stack := dbms_utility.format_error_stack;' || chr(10) ||
      '        l_error_backtrace := dbms_utility.format_error_backtrace;' || chr(10) ||
      '      end if;'
            else
      '      l_error_stack := dbms_utility.format_error_stack;' || chr(10) ||
      '      l_error_backtrace := dbms_utility.format_error_backtrace;'
            end || chr(10) ||
      '  end;' || chr(10) ||
      '  :a_error_stack := l_error_stack;' || chr(10) ||
      '  :a_error_backtrace := l_error_backtrace;' || chr(10) ||
      '  :a_ignored_exception_detected := l_ignored_exception_detected;' || chr(10) ||
      'end;';

      ut_utils.debug_log('ut_executable.do_execute l_statement: ' || l_statement);

      l_cursor_number := dbms_sql.open_cursor;

      /**
      * The code will allow to execute once we check if packages are defined
      * If it fail with 6550 (usually invalid package) it will check if because of invalid state or missing
      * if for any other reason we will propagate it up as we didnt expected.
      **/
      begin
        dbms_sql.parse(l_cursor_number, statement => l_statement, language_flag => dbms_sql.native);
        if l_call_error is null and l_values is not null then
          dbms_sql.bind_variable(l_cursor_number, 'ut_values', l_values);
        elsif l_call_error is null and l_json is not null then
          dbms_sql.bind_variable(l_cursor_number, 'ut_json', l_json);
        end if;
        dbms_sql.bind_variable(l_cursor_number, 'a_error_stack', to_char(null), 32767);
        dbms_sql.bind_variable(l_cursor_number, 'a_error_backtrace', to_char(null), 32767);
        dbms_sql.bind_variable(l_cursor_number, 'a_ignored_exception_detected', to_number(null));
        l_status := dbms_sql.execute(l_cursor_number);
        dbms_sql.variable_value(l_cursor_number, 'a_error_stack', self.error_stack);
        dbms_sql.variable_value(l_cursor_number, 'a_error_backtrace', self.error_backtrace);
        dbms_sql.variable_value(l_cursor_number, 'a_ignored_exception_detected', self.ignored_exception_detected);
        dbms_sql.close_cursor(l_cursor_number);
      exception 
        when ut_utils.ex_invalid_package then
          l_parse_error := dbms_utility.format_error_stack;
          l_failed_with_invalid_pck := is_invalid();
          dbms_sql.close_cursor(l_cursor_number);
          if not l_failed_with_invalid_pck then
            -- the call itself doesn't compile, e.g. arguments that don't fit the parameters;
            -- that is an error of this executable, not of the whole run
            self.error_stack := l_parse_error;
          end if;
        when others then
         dbms_sql.close_cursor(l_cursor_number);
         raise;
      end;
      
      save_dbms_output;
      self.error_stack := coalesce(l_call_error, self.error_stack);

      l_completed_without_errors := (self.error_stack||self.error_backtrace) is null;
      if self.error_stack like '%ORA-04068%' or self.error_stack like '%ORA-04061%' then
        ut_expectation_processor.set_invalidation_exception();
      end if;
    end if;

    --listener - after call to executable
    ut_event_manager.trigger_event('after_'||self.executable_type, self);

    l_end_transaction_id := dbms_transaction.local_transaction_id();
    if l_start_transaction_id != l_end_transaction_id or l_end_transaction_id is null then
      a_item.add_transaction_invalidator(self.form_name());
    end if;

    return l_completed_without_errors;
    
  end do_execute;

  member function get_error_stack_trace return varchar2 is
  begin
    return rtrim(self.error_stack||self.error_backtrace, chr(10));
  end;
end;
/
