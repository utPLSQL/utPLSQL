create or replace type body ut_data_value_number as
  constructor function ut_data_value_number(self in out nocopy ut_data_value_number, a_value number) return self as result is
  begin
    self.value := a_value;
    self.init('number', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
