create or replace type body ut_test_call_params is

  static procedure execute_call(a_owner varchar2, a_object varchar2, a_procedure_name varchar2) is
    stmt varchar2(200);
    i    number;
    c    number;
  
    owner          varchar2(200) := a_owner;
    object_name    varchar2(200) := a_object;
    procedure_name varchar2(200) := a_procedure_name;
  
  begin
  
    ut_metadata.do_resolve(the_owner => owner, the_object => object_name, a_procedure_name => procedure_name);
  
    stmt := 'begin ' || ut_metadata.form_name(owner, object_name, procedure_name) || '; end;';
  
    $if $$ut_trace $then
    dbms_output.put_line('ut_test_call_params.execute_call stmt:' || stmt);
    $end
  
    i := dbms_sql.open_cursor;
    dbms_sql.parse(c => i, statement => stmt, language_flag => dbms_sql.native);
    c := dbms_sql.execute(i);
    dbms_sql.close_cursor(i);
  exception
    when others then
      if i is not null and dbms_sql.is_open(i) then
        dbms_sql.close_cursor(i);
      end if;
      raise;
  end;

  /*
  member function is_valid(self in ut_test_call_params) return boolean is
  begin
    if self.test_procedure is null then
      return false;
    end if;
  
    if not ut_metadata.do_resolve(self.owner_name, self.object_name, self.test_procedure) then
      return false;
    end if;
  
    if self.setup_procedure is not null and
       not ut_metadata.do_resolve(self.owner_name, self.object_name, self.setup_procedure) then
      return false;
    end if;
  
    if self.teardown_procedure is not null and
       not ut_metadata.do_resolve(self.owner_name, self.object_name, self.teardown_procedure) then
      return false;
    end if;
  
    return true;
  end is_valid;
  */

  member function validate_params(a_proc_type varchar2) return boolean is
    a_result boolean := true;
  begin
  
    if self.object_name is null then
      a_result := false;
      ut_assert.report_error('Call params for ' || a_proc_type || ' are not valid: package is not defined');
    end if;
  
    if self.procedure_name is null then
      a_result := false;
      ut_assert.report_error('Call params for ' || a_proc_type || ' are not valid: procedure is not defined');
    end if;
  
    if a_result and not ut_metadata.package_valid(self.owner_name, self.object_name) then
      a_result := false;
      ut_assert.report_error('Call params for ' || a_proc_type ||
                             ' are not valid: package does not exist or is invalid: ' ||
                             nvl(self.object_name, '<missing package name>'));
    end if;
  
    if a_result and not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.procedure_name) then
      a_result := false;
      ut_assert.report_error('Call params for ' || a_proc_type || ' are not valid: package missing ' || a_proc_type ||
                             ' procedure  ' || self.object_name || '.' ||
                             nvl(self.procedure_name, '<missing procedure name>'));
    end if;
  
    return a_result;
  end validate_params;

  member function form_name return varchar2 is
  begin
    return ut_metadata.form_name(owner_name, object_name, procedure_name);
  end;

  member procedure execute(self in ut_test_call_params) is
  begin
    ut_test_call_params.execute_call(self.owner_name, self.object_name, self.procedure_name);
  end execute;

end;
/
