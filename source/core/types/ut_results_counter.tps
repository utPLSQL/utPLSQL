create or replace type ut_results_counter as object(
  /*
  utPLSQL - Version 3
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
  disabled_count integer,
  success_count  integer,
  failure_count  integer,
  errored_count  integer,
  warnings_count integer,
  constructor function ut_results_counter(self in out nocopy ut_results_counter) return self as result,
  member procedure set_counter_values(self in out nocopy ut_results_counter, a_status integer),
  member procedure sum_counter_values(self in out nocopy ut_results_counter, a_item ut_results_counter),
  member procedure increase_warning_count(self in out nocopy ut_results_counter),
  member function total_count return integer,
  member function result_status return integer
)
/
