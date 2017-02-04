create or replace type ut_run authid current_user under ut_suite_item (
  /*
  utPLSQL - Version X.X.X.X 
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License");
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
  * The list of items (suites) to be invoked as part of this run
  */
  items        ut_suite_items,
  constructor function ut_run( self in out nocopy ut_run, a_items ut_suite_items ) return self as result,
  overriding member function  do_execute(self in out nocopy ut_run, a_listener in out nocopy ut_event_listener_base) return boolean,
  overriding member procedure do_execute(self in out nocopy ut_run, a_listener in out nocopy ut_event_listener_base),
  overriding member procedure calc_execution_result(self in out nocopy ut_run)
)
/
