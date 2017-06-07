create or replace type ut_be_greater_than under ut_matcher_bi_operand(
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
  member procedure init(self in out nocopy ut_be_greater_than, a_expected ut_data_value),
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected date) return self as result,
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected number) return self as result,
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected timestamp_unconstrained) return self as result,
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected timestamp_tz_unconstrained) return self as result,
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected timestamp_ltz_unconstrained) return self as result,
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected yminterval_unconstrained) return self as result,
  constructor function ut_be_greater_than(self in out nocopy ut_be_greater_than, a_expected dsinterval_unconstrained) return self as result,
  overriding member function run_matcher(self in out nocopy ut_be_greater_than, a_actual ut_data_value) return boolean,
  overriding member function failure_message(a_actual ut_data_value) return varchar2,
  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2
)
/
