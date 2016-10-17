create or replace type body ut_data_value_timestamp_ltz as

  constructor function ut_data_value_timestamp_ltz(self in out nocopy ut_data_value_timestamp_ltz, a_value timestamp_ltz_unconstrained) return self as result is
  begin
    self.value := a_value;
    self.type := 'timestamp with local time zone';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (self.value is null);
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string(self.value);
  end;

end;
/
