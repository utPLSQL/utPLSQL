create or replace package ut_event_manager authid current_user as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
  subtype t_event_name           is varchar2(250);

    --capture all events
  gc_all                         constant t_event_name := 'all';

  gc_debug                       constant t_event_name := 'debug';

  gc_initialize                  constant t_event_name := 'initialize';

  gc_before_run                  constant t_event_name := 'before_run';
  gc_before_suite                constant t_event_name := 'before_suite';

  gc_before_before_all           constant t_event_name := 'before_beforeall';
  gc_after_before_all            constant t_event_name := 'after_beforeall';
    
  gc_before_test                 constant t_event_name := 'beforetest';

  gc_before_before_each          constant t_event_name := 'before_beforeeach';
  gc_after_before_each           constant t_event_name := 'after_beforeeach';
  gc_before_before_test          constant t_event_name := 'before_beforetest';
  gc_after_before_test           constant t_event_name := 'after_beforetest';

  gc_before_test_execute         constant t_event_name := 'before_test';
  gc_after_test_execute          constant t_event_name := 'after_test';

  gc_before_after_test           constant t_event_name := 'before_aftertest';
  gc_after_after_test            constant t_event_name := 'after_aftertest';
  gc_before_after_each           constant t_event_name := 'before_aftereach';
  gc_after_after_each            constant t_event_name := 'after_aftereach';

  gc_after_test                  constant t_event_name := 'aftertest';

  gc_before_after_all            constant t_event_name := 'before_afterall';
  gc_after_after_all             constant t_event_name := 'after_afterall';

  gc_after_suite                 constant t_event_name := 'after_suite';
  gc_after_run                   constant t_event_name := 'after_run';

  gc_finalize                    constant t_event_name := 'finalize';

  procedure trigger_event( a_event_name t_event_name, a_event_object ut_event_item := null );

  procedure initialize;

  procedure add_listener( a_listener ut_event_listener );

end;
/
