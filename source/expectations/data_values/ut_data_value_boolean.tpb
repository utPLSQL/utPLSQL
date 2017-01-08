create or replace type body ut_data_value_boolean as

  constructor function ut_data_value_boolean(self in out nocopy ut_data_value_boolean, a_value boolean) return self as result is
  begin
    self.data_value := ut_utils.boolean_to_int(a_value);
    self.data_type := 'boolean';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (self.data_value is null);
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string(ut_utils.int_to_boolean(self.data_value));
  end;

end;
/
