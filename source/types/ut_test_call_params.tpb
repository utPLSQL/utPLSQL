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

  member function validate_params(self in ut_test_call_params) return boolean is
    a_result boolean := true;
  begin
  
    if self.object_name is null then
      a_result := false;
      ut_assert.report_error('Test is not invalid: test package is not defined');
    end if;
  
    if self.test_procedure is null then
      a_result := false;
      ut_assert.report_error('Test is not invalid: test procedure is not defined');
    end if;
  
    if a_result and not ut_metadata.package_valid(self.owner_name, self.object_name) then
      a_result := false;
      ut_assert.report_error('package does not exist or is invalid: ' ||
                             nvl(self.object_name, '<missing package name>'));
    end if;
  
    if a_result then
      if not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.test_procedure) then
        ut_assert.report_error('package missing test method ' || self.object_name || '.' ||
                               nvl(self.test_procedure, '<missing procedure name>'));
      end if;
    
      if self.setup_procedure is not null and
         not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.setup_procedure) then
        ut_assert.report_error('package missing setup method ' || self.object_name || '.' ||
                               nvl(self.setup_procedure, '<missing procedure name>'));
      end if;
    
      if self.teardown_procedure is not null and
         not ut_metadata.procedure_exists(self.owner_name, self.object_name, self.teardown_procedure) then
        ut_assert.report_error('package missing teardown method ' || self.object_name || '.' ||
                               nvl(self.teardown_procedure, '<missing procedure name>'));
      end if;
    end if;
    return a_result;
  end validate_params;

  member procedure setup(self in ut_test_call_params) is
  begin
    if self.setup_procedure is not null and self.object_name is not null then
      ut_test_call_params.execute_call(self.owner_name, self.object_name, self.setup_procedure);
    end if;
  end setup;

  member procedure run_test(self in ut_test_call_params) is
  begin
    if self.test_procedure is not null and self.object_name is not null then
      ut_test_call_params.execute_call(self.owner_name, self.object_name, self.test_procedure);
    end if;
  end;

  member procedure teardown(self in ut_test_call_params) is
  begin
    if self.teardown_procedure is not null and self.object_name is not null then
      ut_test_call_params.execute_call(self.owner_name, self.object_name, self.teardown_procedure);
    end if;
  end;

end;
/
