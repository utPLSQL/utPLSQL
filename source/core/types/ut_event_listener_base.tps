create or replace type ut_event_listener_base authid current_user as object(
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
  name varchar2(250),
  member procedure fire_before_event(self in out nocopy ut_event_listener_base, a_event_name varchar2, a_item ut_suite_item_base),
  member procedure fire_after_event(self in out nocopy ut_event_listener_base, a_event_name varchar2, a_item ut_suite_item_base),
  member procedure fire_event(self in out nocopy ut_event_listener_base, a_event_timing varchar2, a_event_name varchar2, a_item ut_suite_item_base)
) not final not instantiable
/
