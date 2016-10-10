create or replace type body ut_data_value_varchar2 as
  constructor function ut_data_value_varchar2(self in out nocopy ut_data_value_varchar2, a_value varchar2) return self as result is
  begin
    self.value := a_value;
    self.init('varchar2', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
