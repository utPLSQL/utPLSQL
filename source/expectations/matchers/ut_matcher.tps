create or replace type ut_matcher under ut_matcher_base(
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
  is_errored      integer,
  is_negated_flag number(1,0),
  expectation     ut_expectation_base,
  /*
    function: run_matcher

    A superclass function that executes the matcher.
    This is actually a fallback function, that should be called by subtype when there is a data type mismatch.
    The subtype should override this function and return:
    - true for success of a matcher,
    - false for faulure of a matcher,
    - null when result cannot be determined (type mismatch or exception)
  */
  member function run_matcher(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean,
  member function run_matcher_negated(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean,
  member function name return varchar2,
  member function description return varchar2,
  member function description_when_negated return varchar2,
  member function error_message(a_actual ut_data_value) return varchar2,
  member function failure_message(a_actual ut_data_value) return varchar2,
  member function failure_message_when_negated(a_actual ut_data_value) return varchar2,
  member procedure negated,
  member function negated return ut_matcher,
  member function is_negated return boolean
) not final not instantiable
/
