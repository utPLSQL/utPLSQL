create or replace type body ut_executable is

  static procedure execute_call(
    a_owner varchar2, a_object varchar2, a_procedure_name varchar2,
    a_error_stack out nocopy varchar2, a_error_backtrace out nocopy varchar2
  ) is
    l_statement      varchar2(4000);
    l_status         number;
    l_cursor_number  number;
    l_owner          varchar2(200) := a_owner;
    l_object_name    varchar2(200) := a_object;
    l_procedure_name varchar2(200) := a_procedure_name;
  
  begin
  
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
    '      --raise on ORA-04068: existing state of packages has been discarded to avoid unrecoverable session exception' || chr(10) ||
    '      if sqlcode = -04068 then' || chr(10) ||
    '        raise;' || chr(10) ||
    '      end if;' || chr(10) ||
    '      l_error_stack := dbms_utility.format_error_stack;' || chr(10) ||
    '      l_error_backtrace := dbms_utility.format_error_backtrace;' || chr(10) ||
    '  end;' || chr(10) ||
    '  :a_error_stack := l_error_stack;' || chr(10) ||
    '  :a_error_backtrace := l_error_backtrace;' || chr(10) ||
    'end;';

    ut_utils.debug_log('ut_executable.execute_call l_statement: ' || l_statement);

    l_cursor_number := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor_number, statement => l_statement, language_flag => dbms_sql.native);
    dbms_sql.bind_variable(l_cursor_number, 'a_error_stack', a_error_stack, 32767);
    dbms_sql.bind_variable(l_cursor_number, 'a_error_backtrace', a_error_backtrace, 32767);

    l_status := dbms_sql.execute(l_cursor_number);
    dbms_sql.variable_value(l_cursor_number, 'a_error_stack', a_error_stack);
    dbms_sql.variable_value(l_cursor_number, 'a_error_backtrace', a_error_backtrace);
    dbms_sql.close_cursor(l_cursor_number);
  end;

  member function is_valid(a_proc_type varchar2) return boolean is
    l_result boolean := true;
  begin
  
    if self.object_name is null then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || a_proc_type || ' are not valid: package is not defined');
    end if;

    if self.procedure_name is null then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || a_proc_type || ' are not valid: procedure is not defined');
    end if;

    if l_result and not ut_metadata.package_valid(self.owner_name, self.object_name) then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || a_proc_type ||
                             ' are not valid: package does not exist or is invalid: ' ||
                             nvl(self.object_name, '<missing package name>'));
    end if;

    if l_result and not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.procedure_name) then
      l_result := false;
      ut_assert_processor.report_error('Call params for ' || a_proc_type || ' are not valid: package missing ' || a_proc_type ||
                             ' procedure  ' || self.object_name || '.' ||
                             nvl(self.procedure_name, '<missing procedure name>'));
    end if;
  
    return l_result;
  end is_valid;

  member function form_name return varchar2 is
  begin
    return ut_metadata.form_name(owner_name, object_name, procedure_name);
  end;

  member procedure do_execute(self in ut_executable) is
    l_error_stack     varchar2(32767);
    l_error_backtrace varchar2(32767);
  begin
    do_execute(l_error_stack, l_error_backtrace);
  end do_execute;

	member procedure do_execute(self in ut_executable, a_error_stack out nocopy varchar2, a_error_backtrace out nocopy varchar2) is
  begin
    ut_executable.execute_call(self.owner_name, self.object_name, self.procedure_name, a_error_stack, a_error_backtrace);
  end do_execute;

end;
/
