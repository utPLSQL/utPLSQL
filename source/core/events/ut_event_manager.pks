create or replace package ut_event_manager authid current_user as
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

  /* Constants: Event names */
  subtype t_event_name           is varchar2(30);
  before_run                     constant t_event_name := 'before_run';
  before_suite                   constant t_event_name := 'before_suite';
  before_before_all              constant t_event_name := 'before_before_all';
  before_before_each             constant t_event_name := 'before_before_each';
  before_before_test             constant t_event_name := 'before_before_test';
  before_test                    constant t_event_name := 'before_test';
  before_test_execute            constant t_event_name := 'before_test_execute';
  before_after_test              constant t_event_name := 'before_after_test';
  before_after_each              constant t_event_name := 'before_after_each';
  before_after_all               constant t_event_name := 'before_after_all';
  after_run                      constant t_event_name := 'after_run';
  after_suite                    constant t_event_name := 'after_suite';
  after_before_all               constant t_event_name := 'after_before_all';
  after_before_each              constant t_event_name := 'after_before_each';
  after_before_test              constant t_event_name := 'after_before_test';
  after_test                     constant t_event_name := 'after_test';
  after_test_execute             constant t_event_name := 'after_test_execute';
  after_after_test               constant t_event_name := 'after_after_test';
  after_after_each               constant t_event_name := 'after_after_each';
  after_after_all                constant t_event_name := 'after_after_all';
  on_finalize                    constant t_event_name := 'on_finalize';

  procedure trigger_event( a_event_name t_event_name, a_event_object ut_event_item );

  procedure initialize;

  procedure add_listener( a_listener ut_event_listener );

end;
/
