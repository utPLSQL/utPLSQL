create or replace type body ut_data_value_date as
  constructor function ut_data_value_date(self in out nocopy ut_data_value_date, a_value date) return self as result is
  begin
    self.value := a_value;
    self.init('date', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
