create or replace type body ut_data_value_refcursor as

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result is
    l_crsr sys_refcursor := a_value;
  begin
    if a_value is not null then
      self.value := dbms_sql.to_cursor_number(l_crsr);
    end if;
    self.init('refcursor', ut_utils.boolean_to_int(a_value is null), null);
    return;
  end;

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value varchar2) return self as result is
    l_crsr sys_refcursor;
  begin
    if a_value is not null then
      open l_crsr for a_value;
      self.value := dbms_sql.to_cursor_number(l_crsr);
    end if;
    self.init('refcursor', ut_utils.boolean_to_int(a_value is null), null);
    return;
  end;

end;
/
