create or replace type ut_debug_reporter under ut_output_reporter_base(
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

  constructor function ut_debug_reporter(self in out nocopy ut_debug_reporter) return self as result,
  /**
  * Returns the list of events that are supported by particular implementation of the reporter
  */
  overriding member function get_supported_events return ut_varchar2_list,

  /**
  * Delegates execution of event into individual reporting procedures
  */
  overriding member procedure on_event( self in out nocopy ut_debug_reporter, a_event_name varchar2, a_event_item ut_event_item)

)
/