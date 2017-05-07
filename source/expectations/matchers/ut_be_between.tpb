create or replace type body ut_be_between is
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  member procedure init(self in out nocopy ut_be_between, a_lower_bound ut_data_value, a_upper_bound ut_data_value) is
  begin
    self.self_type       := $$plsql_unit;
    self.lower_bound     := a_lower_bound;
    self.upper_bound     := a_upper_bound;
  end;

  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound date, a_upper_bound date)
    return self as result is
  begin
    init(ut_data_value_date(a_lower_bound), ut_data_value_date(a_upper_bound));
    return;
  end;
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound number, a_upper_bound number)
    return self as result is
  begin
    init(ut_data_value_number(a_lower_bound), ut_data_value_number(a_upper_bound));
    return;
  end;
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound varchar2, a_upper_bound varchar2)
    return self as result is
  begin
    init(ut_data_value_varchar2(a_lower_bound), ut_data_value_varchar2(a_upper_bound));
    return;
  end;
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp(a_lower_bound), ut_data_value_timestamp(a_upper_bound));
    return;
  end;
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp_tz(a_lower_bound), ut_data_value_timestamp_tz(a_upper_bound));
    return;
  end;
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp_ltz(a_lower_bound), ut_data_value_timestamp_ltz(a_upper_bound));
    return;
  end;

  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained)
    return self as result is
  begin
    init(ut_data_value_yminterval(a_lower_bound), ut_data_value_yminterval(a_upper_bound));
    return;
  end;

  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)
    return self as result is
  begin
    init(ut_data_value_dsinterval(a_lower_bound), ut_data_value_dsinterval(a_upper_bound));
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_between, a_actual ut_data_value) return boolean is
    l_lower_result boolean;
    l_upper_result boolean;
    l_result boolean;
  begin
    if self.lower_bound.data_type = a_actual.data_type then
      l_lower_result := a_actual >= self.lower_bound;
      l_upper_result := a_actual <= self.upper_bound;
      if l_lower_result is not null and l_upper_result is not null then
        l_result := l_lower_result and l_upper_result;
      end if;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
  begin
    return (self as ut_matcher).failure_message(a_actual)
           || ': '|| self.lower_bound.to_string_report(true,false)
           || ' and ' || self.upper_bound.to_string_report(a_with_type_name => false);
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual)
           || ': '|| self.lower_bound.to_string_report(true,false)
           || ' and ' || self.upper_bound.to_string_report(a_with_type_name => false);
  end;

end;
/
