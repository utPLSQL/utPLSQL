create or replace type ut_include under ut_equal(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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
  is_negated number(1,0),  
    
  constructor function ut_include(self in out nocopy ut_include, a_expected sys_refcursor) return self as result,
  member function get_inclusion_compare return boolean,
  member function negated return ut_include,
  member function get_negated return boolean,
  overriding member function run_matcher(self in out nocopy ut_include, a_actual ut_data_value) return boolean,
  overriding member function run_matcher_negated(self in out nocopy ut_include, a_actual ut_data_value) return boolean,
  overriding member function failure_message(a_actual ut_data_value) return varchar2,
  overriding member function failure_message_when_negated(a_actual ut_data_value) return varchar2
)
/
