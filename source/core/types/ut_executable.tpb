create or replace type body ut_executable is

  static procedure execute_call(a_owner varchar2, a_object varchar2, a_procedure_name varchar2) is
    l_stmt varchar2(200);
    l_cursorid    number;
    l_rowsprocessed    number;
  
    l_owner          varchar2(200) := a_owner;
    l_object_name    varchar2(200) := a_object;
    l_procedure_name varchar2(200) := a_procedure_name;
  
  begin
  
    ut_metadata.do_resolve(a_owner => l_owner, a_object => l_object_name, a_procedure_name => l_procedure_name);
  
    l_stmt := 'begin ' || ut_metadata.form_name(l_owner, l_object_name, l_procedure_name) || '; end;';
  
    ut_utils.debug_log('ut_executable.execute_call stmt:' || l_stmt);

    l_cursorid := dbms_sql.open_cursor;
    dbms_sql.parse(c => l_cursorid, statement => l_stmt, language_flag => dbms_sql.native);
    l_rowsprocessed := dbms_sql.execute(l_cursorid);
    dbms_sql.close_cursor(l_cursorid);
  exception
    when others then
      if l_cursorid is not null and dbms_sql.is_open(l_cursorid) then
        dbms_sql.close_cursor(l_cursorid);
      end if;
      raise;
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
  begin
    ut_executable.execute_call(self.owner_name, self.object_name, self.procedure_name);
  end do_execute;

end;
/
