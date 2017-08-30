create or replace type body ut_executable is
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

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

  constructor function ut_executable(
    self in out nocopy ut_executable, a_context ut_suite_item,
    a_procedure_name varchar2, a_associated_event_name varchar2
  ) return self as result is
  begin
    self.associated_event_name := a_associated_event_name;
    self.owner_name := a_context.object_owner;
    self.object_name := a_context.object_name;
    self.procedure_name := a_procedure_name;
    return;
  end;

  member function is_defined return boolean is
  begin
    return self.procedure_name is not null and self.object_name is not null;
  end;

  member function is_valid(self in out nocopy ut_executable) return boolean is
    l_result boolean := false;
    l_message_part varchar2(4000) := 'Call params for ' || self.associated_event_name || ' are not valid: ';
  begin

    if self.object_name is null then
      self.error_stack := l_message_part || 'package is not defined';
    elsif not ut_metadata.package_valid(self.owner_name, self.object_name) then
      self.error_stack := l_message_part || 'package does not exist or is invalid: ' ||upper(self.owner_name||'.'||self.object_name);
    elsif self.procedure_name is null then
      self.error_stack := l_message_part || 'procedure is not defined';
    elsif not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.procedure_name) then
      self.error_stack := l_message_part || 'package missing procedure  '
                          || upper(self.owner_name || '.' || self.object_name || '.' ||self.procedure_name);
    else
      l_result := true;
    end if;

    return l_result;
  end is_valid;

  member function form_name return varchar2 is
  begin
    return ut_metadata.form_name(owner_name, object_name, procedure_name);
  end;

  member procedure do_execute(self in out nocopy ut_executable, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_listener);
  end do_execute;

	member function do_execute(self in out nocopy ut_executable, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_statement                varchar2(4000);
    l_status                   number;
    l_cursor_number            number;
    l_owner                    varchar2(200) := self.owner_name;
    l_object_name              varchar2(200) := self.object_name;
    l_procedure_name           varchar2(200) := self.procedure_name;

    l_completed_without_errors boolean := true;
    l_start_transaction_id     varchar2(250);
    l_end_transaction_id     varchar2(250);
    procedure save_dbms_output is
      l_status number;
      l_line varchar2(32767);
    begin
      dbms_lob.createtemporary(self.serveroutput, true, dur => dbms_lob.session);

      loop
        dbms_output.get_line(line => l_line, status => l_status);
        exit when l_status = 1;

        if l_line is not null then
          ut_utils.append_to_clob(self.serveroutput, l_line);
        end if;

        dbms_lob.writeappend(self.serveroutput,1,chr(10));
      end loop;
    end save_dbms_output;
  begin
    if self.is_defined() then
      l_start_transaction_id := dbms_transaction.local_transaction_id(true);
      
      -- report to application_info
      ut_utils.set_client_info(self.procedure_name);
      
      --listener - before call to executable
      a_listener.fire_before_event(self.associated_event_name, a_item);

      ut_metadata.do_resolve(a_owner => l_owner, a_object => l_object_name, a_procedure_name => l_procedure_name);

      l_statement :=
      'declare' || chr(10) ||
      '  l_error_stack varchar2(32767);' || chr(10) ||
      '  l_error_backtrace varchar2(32767);' || chr(10) ||
      'begin' || chr(10) ||
      '  begin' || chr(10) ||
      '    ' || ut_metadata.form_name(l_owner, l_object_name, l_procedure_name) || ';' || chr(10) ||
      '  exception' || chr(10) ||
      '    when others then ' || chr(10) ||
      '      l_error_stack := dbms_utility.format_error_stack;' || chr(10) ||
      '      l_error_backtrace := dbms_utility.format_error_backtrace;' || chr(10) ||
      '      --raise on ORA-04068, ORA-04061: existing state of packages has been discarded to avoid unrecoverable session exception' || chr(10) ||
      '      if l_error_stack like ''%ORA-04068%'' or l_error_stack like ''%ORA-04061%'' then' || chr(10) ||
      '        raise;' || chr(10) ||
      '      end if;' || chr(10) ||
      '  end;' || chr(10) ||
      '  :a_error_stack := l_error_stack;' || chr(10) ||
      '  :a_error_backtrace := l_error_backtrace;' || chr(10) ||
      'end;';

      ut_utils.debug_log('ut_executable.do_execute l_statement: ' || l_statement);

      l_cursor_number := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor_number, statement => l_statement, language_flag => dbms_sql.native);
      dbms_sql.bind_variable(l_cursor_number, 'a_error_stack', to_char(null), 32767);
      dbms_sql.bind_variable(l_cursor_number, 'a_error_backtrace', to_char(null), 32767);

      l_status := dbms_sql.execute(l_cursor_number);
      dbms_sql.variable_value(l_cursor_number, 'a_error_stack', self.error_stack);
      dbms_sql.variable_value(l_cursor_number, 'a_error_backtrace', self.error_backtrace);
      dbms_sql.close_cursor(l_cursor_number);

      save_dbms_output;

      l_completed_without_errors := (self.error_stack||self.error_backtrace) is null;

      --listener - after call to executable
      a_listener.fire_after_event(self.associated_event_name, a_item);

      l_end_transaction_id := dbms_transaction.local_transaction_id();
      if l_start_transaction_id != l_end_transaction_id or l_end_transaction_id is null then
        a_item.add_transaction_invalidator(self.form_name());
      end if;
      ut_utils.set_client_info(null);
    end if;

    return l_completed_without_errors;
  end do_execute;

  member function get_error_stack_trace return varchar2 is
  begin
    return rtrim(self.error_stack||self.error_backtrace, chr(10));
  end;
end;
/
