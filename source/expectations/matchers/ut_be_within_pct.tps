create or replace type ut_be_within_pct force under ut_comparison_matcher(
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


  /**
  * Holds information about mather options
  */
  distance_from_expected ut_data_value,

  constructor function ut_be_within_pct(self in out nocopy ut_be_within_pct, a_pct_of_expected number) return self as result,
  member procedure init(self in out nocopy ut_be_within_pct, a_distance_from_expected ut_data_value, self_type varchar2),
  member procedure of_(self in ut_be_within_pct, a_expected number),
  member function of_(self in ut_be_within_pct, a_expected number) return ut_be_within_pct,
  overriding member function run_matcher(self in out nocopy ut_be_within_pct, a_actual ut_data_value) return boolean,
  overriding member function failure_message(a_actual ut_data_value) return varchar2,
  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2,
  overriding member function error_message(a_actual ut_data_value) return varchar2
)
not final
/
