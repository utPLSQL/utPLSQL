create or replace type body ut_be_less_or_equal AS
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

  member procedure init(self in out nocopy ut_be_less_or_equal, a_expected ut_data_value) is
  begin
    self.name := 'be less or equal';
    self.expected := a_expected;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected date) return self as result is
  begin
    init(ut_data_value_date(a_expected));
    return;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected NUMBER) return self as result is
  begin
    init(ut_data_value_number(a_expected));
    return;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected timestamp_unconstrained) return self as result is
  begin
    init(ut_data_value_timestamp(a_expected));
    return;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected timestamp_tz_unconstrained) return self as result is
  begin
    init(ut_data_value_timestamp_tz(a_expected));
    return;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected timestamp_ltz_unconstrained) return self as result is
  begin
    init(ut_data_value_timestamp_ltz(a_expected));
    return;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected yminterval_unconstrained) return self as RESULT IS
  begin
    init(ut_data_value_yminterval(a_expected));
    return;
  end;

  constructor function ut_be_less_or_equal(self in out nocopy ut_be_less_or_equal, a_expected dsinterval_unconstrained) return self as RESULT IS
  begin
    init(ut_data_value_dsinterval(a_expected));
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_less_or_equal, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if self.expected is of (ut_data_value_date) and a_actual is of (ut_data_value_date) then
      declare
        l_expected ut_data_value_date := treat(self.expected as ut_data_value_date);
        l_actual   ut_data_value_date := treat(a_actual as ut_data_value_date);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    elsif self.expected is of (ut_data_value_number) and a_actual is of (ut_data_value_number) then
      declare
        l_expected ut_data_value_number := treat(self.expected as ut_data_value_number);
        l_actual   ut_data_value_number := treat(a_actual as ut_data_value_number);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    elsif self.expected is of (ut_data_value_timestamp) and a_actual is of (ut_data_value_timestamp) then
      declare
        l_expected ut_data_value_timestamp := treat(self.expected as ut_data_value_timestamp);
        l_actual   ut_data_value_timestamp := treat(a_actual as ut_data_value_timestamp);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    elsif self.expected is of (ut_data_value_timestamp_ltz) and a_actual is of (ut_data_value_timestamp_ltz) then
      declare
        l_expected ut_data_value_timestamp_ltz := treat(self.expected as ut_data_value_timestamp_ltz);
        l_actual   ut_data_value_timestamp_ltz := treat(a_actual as ut_data_value_timestamp_ltz);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    elsif self.expected is of (ut_data_value_timestamp_tz) and a_actual is of (ut_data_value_timestamp_tz) then
      declare
        l_expected ut_data_value_timestamp_tz := treat(self.expected as ut_data_value_timestamp_tz);
        l_actual   ut_data_value_timestamp_tz := treat(a_actual as ut_data_value_timestamp_tz);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    elsif self.expected is of (ut_data_value_yminterval) and a_actual is of (ut_data_value_yminterval) then
      declare
        l_expected ut_data_value_yminterval := treat(self.expected as ut_data_value_yminterval);
        l_actual   ut_data_value_yminterval := treat(a_actual as ut_data_value_yminterval);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    elsif self.expected is of (ut_data_value_dsinterval) and a_actual is of (ut_data_value_dsinterval) then
      declare
        l_expected ut_data_value_dsinterval := treat(self.expected as ut_data_value_dsinterval);
        l_actual   ut_data_value_dsinterval := treat(a_actual as ut_data_value_dsinterval);
      begin
        l_result := l_actual.data_value <= l_expected.data_value;
      end;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

END;
/
