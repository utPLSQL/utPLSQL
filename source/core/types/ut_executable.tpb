create or replace type body ut_executable is

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

  member function is_valid return boolean is
    l_result boolean := true;
  begin

    if self.object_name is null then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || self.associated_event_name || ' are not valid: package is not defined');
    end if;

    if self.procedure_name is null then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || self.associated_event_name || ' are not valid: procedure is not defined');
    end if;

    if l_result and not ut_metadata.package_valid(self.owner_name, self.object_name) then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || self.associated_event_name ||
                             ' are not valid: package does not exist or is invalid: ' ||nvl(self.owner_name, '<missing schema name>')||'.'||
                             nvl(self.object_name, '<missing package name>'));
    end if;

    if l_result and not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.procedure_name) then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || self.associated_event_name || ' are not valid: package missing ' ||
                             ' procedure  ' || self.object_name || '.' ||
                             nvl(self.procedure_name, '<missing procedure name>'));
    end if;

    return l_result;
  end is_valid;

  member function form_name return varchar2 is
  begin
    return ut_metadata.form_name(owner_name, object_name, procedure_name);
  end;

  member procedure do_execute(self in ut_executable, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors  boolean;
  begin
    l_completed_without_errors := self.do_execute(a_item, a_listener);
  end do_execute;

	member function do_execute(self in ut_executable, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_statement      varchar2(4000);
    l_status         number;
    l_cursor_number  number;
    l_owner          varchar2(200) := self.owner_name;
    l_object_name    varchar2(200) := self.object_name;
    l_procedure_name varchar2(200) := self.procedure_name;

    l_error_stack     varchar2(32767);
    l_error_backtrace varchar2(32767);
    l_completed_without_errors boolean := true;

    function process_errors_from_call(a_error_stack varchar2, a_error_backtrace varchar2) return boolean is
      l_errors_stack_trace varchar2(32767) := rtrim(a_error_stack||a_error_backtrace, chr(10));
    begin
      if l_errors_stack_trace is not null then
        ut_utils.debug_log('test method failed- ' ||l_errors_stack_trace );
        ut_assert_processor.report_error( l_errors_stack_trace );
        return false;
      else
        return true;
      end if;
    end;
  begin
    if self.is_defined() then
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
      dbms_sql.bind_variable(l_cursor_number, 'a_error_stack', l_error_stack, 32767);
      dbms_sql.bind_variable(l_cursor_number, 'a_error_backtrace', l_error_backtrace, 32767);

      l_status := dbms_sql.execute(l_cursor_number);
      dbms_sql.variable_value(l_cursor_number, 'a_error_stack', l_error_stack);
      dbms_sql.variable_value(l_cursor_number, 'a_error_backtrace', l_error_backtrace);
      dbms_sql.close_cursor(l_cursor_number);

      l_completed_without_errors := process_errors_from_call(l_error_stack, l_error_backtrace);

      a_listener.fire_after_event(self.associated_event_name, a_item);
      --listener - after call to executable
    end if;
    return l_completed_without_errors;
  end do_execute;

end;
/
