create or replace package ut_event_manager authid current_user as
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
  subtype t_event_name           is varchar2(250);

  procedure trigger_event( a_event_name t_event_name, a_event_object ut_event_item );

  procedure initialize;

  procedure add_listener( a_listener ut_event_listener );

end;
/
