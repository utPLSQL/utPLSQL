create or replace type body ut_data_value_blob as
  constructor function ut_data_value_blob(self in out nocopy ut_data_value_blob, a_value blob) return self as result is
  begin
    self.value := a_value;
    self.init('blob', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
