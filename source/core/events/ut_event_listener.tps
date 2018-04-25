create or replace type ut_event_listener authid definer as object (
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

  /**
  * Object type is a pre-declaration to be referenced by ut_event_listener_base
  * The true abstract type is ut_suite_item
  */
  self_type    varchar2(250 byte),

  /**
  * Returns the list of events that are supported by particular implementation of the reporter
  */
  not instantiable member function get_supported_events return ut_varchar2_list,

  /**
  * Executes an action for a given event name
  */
  not instantiable member procedure on_event( self in out nocopy ut_event_listener, a_event_name varchar2, a_event_item ut_event_item)
) not final not instantiable
/
