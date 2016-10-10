create or replace type body ut_data_value_timestamp_tz as
  constructor function ut_data_value_timestamp_tz(self in out nocopy ut_data_value_timestamp_tz, a_value timestamp_tz_unconstrained) return self as result is
  begin
    self.value := a_value;
    self.init('timestamp with time zone', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
