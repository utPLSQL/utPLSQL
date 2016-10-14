create or replace type body ut_data_value_anydata as
  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result is
  begin
    self.value := a_value;
    self.init('anydata', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(xmltype(a_value).getclobval()));
    return;
  end;
end;
/
