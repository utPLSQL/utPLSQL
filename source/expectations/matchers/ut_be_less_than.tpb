create or replace type body ut_be_less_than as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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

  member procedure init(self in out nocopy ut_be_less_than, a_expected ut_data_value) is
  begin
    self.self_type := $$plsql_unit;
    self.expected  := a_expected;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected date) return self as result is
  begin
    init(ut_data_value_date(a_expected));
    return;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected number) return self as result is
  begin
    init(ut_data_value_number(a_expected));
    return;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected timestamp_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp(a_expected));
    return;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected timestamp_tz_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp_tz(a_expected));
    return;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected timestamp_ltz_unconstrained)
    return self as result is
  begin
    init(ut_data_value_timestamp_ltz(a_expected));
    return;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected yminterval_unconstrained)
    return self as result is
  begin
    init(ut_data_value_yminterval(a_expected));
    return;
  end;

  constructor function ut_be_less_than(self in out nocopy ut_be_less_than, a_expected dsinterval_unconstrained)
    return self as result is
  begin
    init(ut_data_value_dsinterval(a_expected));
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_less_than, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected.data_type = a_actual.data_type then
        l_result := a_actual < self.expected;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

  overriding member function failure_message(a_actual ut_data_value) return varchar2 is
  begin
    return (self as ut_matcher).failure_message(a_actual) || ': '|| expected.to_string_report();
  end;

  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2 is
  begin
    return (self as ut_matcher).failure_message_when_negated(a_actual) || ': '|| expected.to_string_report();
  end;

end;
/
