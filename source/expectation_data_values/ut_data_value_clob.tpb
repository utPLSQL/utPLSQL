create or replace type body ut_data_value_clob as
  constructor function ut_data_value_clob(self in out nocopy ut_data_value_clob, a_value clob) return self as result is
  begin
    self.value := a_value;
    self.init('clob', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
