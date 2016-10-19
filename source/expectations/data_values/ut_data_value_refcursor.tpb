create or replace type body ut_data_value_refcursor as

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result is
  begin
    if a_value is not null then
      self.value := dbms_xmlgen.newContext(a_value);
    end if;
    self.type := 'refcursor';
    return;
  end;

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value varchar2) return self as result is
    l_crsr sys_refcursor;
  begin
    if a_value is not null then
      open l_crsr for a_value;
      self.value := dbms_xmlgen.newContext(l_crsr);
    end if;
    self.type := 'refcursor';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (self.value is null);
  end;

  overriding member function to_string return varchar2 is
    l_result clob;
  begin
    if self.value is not null then
      ut_assert_processor.set_xml_nls_params();
      dbms_xmlgen.setMaxRows(self.value, 100);
      l_result := dbms_xmlgen.getxml(self.value);
      dbms_xmlgen.restartQuery(self.value);
      ut_assert_processor.reset_nls_params();
    end if;
    return ut_utils.to_string(l_result);
  end;

end;
/
