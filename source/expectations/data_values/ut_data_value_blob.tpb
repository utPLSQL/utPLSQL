create or replace type body ut_data_value_blob as

  constructor function ut_data_value_blob(self in out nocopy ut_data_value_blob, a_value blob) return self as result is
  begin
    self.datavalue := a_value;
    self.datatype := 'blob';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (self.datavalue is null);
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string(self.datavalue);
  end;

end;
/
