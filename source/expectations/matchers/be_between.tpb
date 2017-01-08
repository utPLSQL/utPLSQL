create or replace type body be_between is

  member procedure init(self in out nocopy be_between, a_lower_bound ut_data_value, a_upper_bound ut_data_value) is
  begin
    self.name            := lower($$plsql_unit);
    self.lower_bound     := a_lower_bound;
    self.upper_bound     := a_upper_bound;
    self.additional_info := 'between ' || a_lower_bound.to_string || ' and ' || a_upper_bound.to_string;
  end;

  constructor function be_between(self in out nocopy be_between, a_lower_bound date, a_upper_bound date)
    return self as result is
  begin
    init(ut_data_value_date(a_lower_bound), ut_data_value_date(a_upper_bound));
    return;
  end;
  constructor function be_between(self in out nocopy be_between, a_lower_bound number, a_upper_bound number)
    return self as result is
  begin
    init(ut_data_value_number(a_lower_bound), ut_data_value_number(a_upper_bound));
    return;
  end;
  constructor function be_between(self in out nocopy be_between, a_lower_bound varchar2, a_upper_bound varchar2)
    return self as result is
  begin
    init(ut_data_value_varchar2(a_lower_bound), ut_data_value_varchar2(a_upper_bound));
    return;
  end;
  constructor function be_between(self in out nocopy be_between, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp(a_lower_bound), ut_data_value_timestamp(a_upper_bound));
    return;
  end;
  constructor function be_between(self in out nocopy be_between, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp_tz(a_lower_bound), ut_data_value_timestamp_tz(a_upper_bound));
    return;
  end;
  constructor function be_between(self in out nocopy be_between, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp_ltz(a_lower_bound), ut_data_value_timestamp_ltz(a_upper_bound));
    return;
  end;

  constructor function be_between(self in out nocopy be_between, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained)
    return self as result is
  begin
    init(ut_data_value_yminterval(a_lower_bound), ut_data_value_yminterval(a_upper_bound));
    return;
  end;

  constructor function be_between(self in out nocopy be_between, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)
    return self as result is
  begin
    init(ut_data_value_dsinterval(a_lower_bound), ut_data_value_dsinterval(a_upper_bound));
    return;
  end;

  overriding member function run_matcher(self in out nocopy be_between, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.lower_bound is of(ut_data_value_date) and self.upper_bound is of(ut_data_value_date) and a_actual is of(ut_data_value_date) then
      declare
        l_lower  ut_data_value_date := treat(self.lower_bound as ut_data_value_date);
        l_upper  ut_data_value_date := treat(self.upper_bound as ut_data_value_date);
        l_actual ut_data_value_date := treat(a_actual as ut_data_value_date);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_number) and self.upper_bound is of(ut_data_value_number) and a_actual is of(ut_data_value_number) then
      declare
        l_lower  ut_data_value_number := treat(self.lower_bound as ut_data_value_number);
        l_upper  ut_data_value_number := treat(self.upper_bound as ut_data_value_number);
        l_actual ut_data_value_number := treat(a_actual as ut_data_value_number);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_varchar2) and self.upper_bound is of(ut_data_value_varchar2) and a_actual is of(ut_data_value_varchar2) then
      declare
        l_lower  ut_data_value_varchar2 := treat(self.lower_bound as ut_data_value_varchar2);
        l_upper  ut_data_value_varchar2 := treat(self.upper_bound as ut_data_value_varchar2);
        l_actual ut_data_value_varchar2 := treat(a_actual as ut_data_value_varchar2);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_timestamp) and self.upper_bound is of(ut_data_value_timestamp) and a_actual is of(ut_data_value_timestamp) then
      declare
        l_lower  ut_data_value_timestamp := treat(self.lower_bound as ut_data_value_timestamp);
        l_upper  ut_data_value_timestamp := treat(self.upper_bound as ut_data_value_timestamp);
        l_actual ut_data_value_timestamp := treat(a_actual as ut_data_value_timestamp);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_timestamp_tz) and self.upper_bound is of(ut_data_value_timestamp_tz) and a_actual is of(ut_data_value_timestamp_tz) then
      declare
        l_lower  ut_data_value_timestamp_tz := treat(self.lower_bound as ut_data_value_timestamp_tz);
        l_upper  ut_data_value_timestamp_tz := treat(self.upper_bound as ut_data_value_timestamp_tz);
        l_actual ut_data_value_timestamp_tz := treat(a_actual as ut_data_value_timestamp_tz);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_timestamp_ltz) and self.upper_bound is of(ut_data_value_timestamp_ltz) and a_actual is of(ut_data_value_timestamp_ltz) then
      declare
        l_lower  ut_data_value_timestamp_ltz := treat(self.lower_bound as ut_data_value_timestamp_ltz);
        l_upper  ut_data_value_timestamp_ltz := treat(self.upper_bound as ut_data_value_timestamp_ltz);
        l_actual ut_data_value_timestamp_ltz := treat(a_actual as ut_data_value_timestamp_ltz);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_yminterval) and self.upper_bound is of(ut_data_value_yminterval) and a_actual is of(ut_data_value_yminterval) then
      declare
        l_lower  ut_data_value_yminterval := treat(self.lower_bound as ut_data_value_yminterval);
        l_upper  ut_data_value_yminterval := treat(self.upper_bound as ut_data_value_yminterval);
        l_actual ut_data_value_yminterval := treat(a_actual as ut_data_value_yminterval);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    elsif self.lower_bound is of(ut_data_value_dsinterval) and self.upper_bound is of(ut_data_value_dsinterval) and a_actual is of(ut_data_value_dsinterval) then
      declare
        l_lower  ut_data_value_dsinterval := treat(self.lower_bound as ut_data_value_dsinterval);
        l_upper  ut_data_value_dsinterval := treat(self.upper_bound as ut_data_value_dsinterval);
        l_actual ut_data_value_dsinterval := treat(a_actual as ut_data_value_dsinterval);
      begin
        l_result := l_actual.data_value between l_lower.data_value and l_upper.data_value;
      end;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

end;
/
