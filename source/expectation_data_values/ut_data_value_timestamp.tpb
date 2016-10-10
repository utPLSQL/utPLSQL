create or replace type body ut_data_value_timestamp as
  constructor function ut_data_value_timestamp(self in out nocopy ut_data_value_timestamp, a_value timestamp_unconstrained) return self as result is
  begin
    self.value := a_value;
    self.init('timestamp', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
