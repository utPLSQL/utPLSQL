create or replace type body ut_data_value_boolean as
  constructor function ut_data_value_boolean(self in out nocopy ut_data_value_boolean, a_value boolean) return self as result is
  begin
    self.value := ut_utils.boolean_to_int(a_value);
    self.init('boolean', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
