create or replace package body ut_event_manager  as
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

  type t_listeners is table of ut_event_listener;
  subtype t_listener_number is binary_integer;
  type t_listener_numbers is table of boolean index by t_listener_number;
  type t_events_listeners is table of t_listener_numbers index by t_event_name;

  gc_event_listeners_index t_events_listeners;
  gc_listeners             t_listeners;

  procedure initialize is
  begin
    gc_event_listeners_index.delete;
    gc_listeners := t_listeners();
  end;

  procedure trigger_event( a_event_name t_event_name, a_event_object ut_event_item ) is
  begin
    if a_event_name is not null and gc_event_listeners_index.exists(a_event_name)
       and gc_event_listeners_index(a_event_name) is not null
    then
      for listener_number in 1 .. gc_event_listeners_index(a_event_name).count loop
        gc_listeners(listener_number).on_event(a_event_name, a_event_object);
      end loop;
    end if;
  end;

  procedure add_event( a_event_name t_event_name, a_listener_pos binary_integer ) is
  begin
    gc_event_listeners_index(a_event_name)(a_listener_pos) := true;
  end;

  procedure add_events( a_event_names ut_varchar2_list, a_listener_pos binary_integer ) is
  begin
    for i in 1 .. a_event_names.count loop
      add_event(a_event_names(i), a_listener_pos);
    end loop;
  end;

  function add_listener( a_listener ut_event_listener ) return t_listener_number is
  begin
    if gc_listeners is null then
      gc_listeners := t_listeners();
    end if;
    gc_listeners.extend;
    gc_listeners(gc_listeners.last) := a_listener;
    return gc_listeners.last;
  end;

  procedure add_listener( a_listener ut_event_listener ) is
    l_event_names ut_varchar2_list;
  begin
    if a_listener is not null then
      l_event_names := a_listener.get_supported_events();
      if l_event_names is not empty then
        add_events( l_event_names, add_listener(a_listener ) );
      end if;
    end if;

  end;

end;
/
