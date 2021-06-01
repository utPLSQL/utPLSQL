create or replace type ut_be_within under ut_be_within_pct(
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


  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected number) return self as result,
  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected dsinterval_unconstrained) return self as result,
  constructor function ut_be_within(self in out nocopy ut_be_within, a_distance_from_expected yminterval_unconstrained) return self as result,
  member procedure of_(self in ut_be_within, a_expected date),
  member function of_(self in ut_be_within, a_expected date)  return ut_be_within,
  member procedure of_(self in ut_be_within, a_expected timestamp),
  member function of_(self in ut_be_within, a_expected timestamp)  return ut_be_within,  
  member procedure of_(self in ut_be_within, a_expected timestamp_tz_unconstrained ),
  member function of_(self in ut_be_within, a_expected timestamp_tz_unconstrained)  return ut_be_within,   
  member procedure of_(self in ut_be_within, a_expected timestamp_ltz_unconstrained),
  member function of_(self in ut_be_within, a_expected timestamp_ltz_unconstrained) return ut_be_within,      
  overriding member function run_matcher(self in out nocopy ut_be_within, a_actual ut_data_value) return boolean,
  overriding member function failure_message(a_actual ut_data_value) return varchar2,
  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2
)
not final
/
