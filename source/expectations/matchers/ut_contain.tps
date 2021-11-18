create or replace type ut_contain under ut_equal(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
  * Due to nature of inclusion compare the not is bit diffrente than standard.
  * Result is false when even one element belongs which can cause overlap.
  * e.g. set can fail at same time not_include and include. By that we mean
  * that false include not necessary mean true not include.
  */

  constructor function ut_contain(self in out nocopy ut_contain, a_expected sys_refcursor) return self as result,
  constructor function ut_contain(self in out nocopy ut_contain, a_expected anydata) return self as result,
  overriding member function run_matcher(self in out nocopy ut_contain, a_actual ut_data_value) return boolean,
  overriding member function run_matcher_negated(self in out nocopy ut_contain, a_actual ut_data_value) return boolean,
  overriding member function failure_message(a_actual ut_data_value) return varchar2,
  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2
)
/
