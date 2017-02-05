create or replace type ut_be_between under ut_matcher(
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
  lower_bound ut_data_value,
  upper_bound ut_data_value,

  member procedure init(self in out nocopy ut_be_between, a_lower_bound ut_data_value, a_upper_bound ut_data_value),

  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound date, a_upper_bound date)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound number, a_upper_bound number)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound varchar2, a_upper_bound varchar2)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained)
    return self as result,
  constructor function ut_be_between(self in out nocopy ut_be_between, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)
    return self as result,

  overriding member function run_matcher(self in out nocopy ut_be_between, a_actual ut_data_value) return boolean
)
/
