create or replace type body ut_data_value_timestamp_ltz as
  constructor function ut_data_value_timestamp_ltz(self in out nocopy ut_data_value_timestamp_ltz, a_value timestamp_ltz_unconstrained) return self as result is
  begin
    self.value := a_value;
    self.init('timestamp with local time zone', ut_utils.boolean_to_int(a_value is null), ut_utils.to_string(a_value));
    return;
  end;
end;
/
