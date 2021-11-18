create or replace package body ut_event_manager  as
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

  type t_listeners is table of ut_event_listener;
  subtype t_listener_number is binary_integer;
  type t_listener_numbers is table of boolean index by t_listener_number;
  type t_events_listeners is table of t_listener_numbers index by t_event_name;

  type t_event_manager is record (
    event_listener_index t_events_listeners,
    listeners            t_listeners
  );
  type t_event_managers is table of t_event_manager;

  g_event_listeners_index    t_events_listeners;
  g_listeners                t_listeners;
  g_suspended_event_managers t_event_managers;

  procedure initialize is
  begin
    if g_listeners is not null and g_listeners.count > 0 then
       if g_suspended_event_managers is null then
         g_suspended_event_managers := t_event_managers();
       end if;
       g_suspended_event_managers.extend;
       g_suspended_event_managers(g_suspended_event_managers.count).event_listener_index := g_event_listeners_index;
       g_suspended_event_managers(g_suspended_event_managers.count).listeners            := g_listeners;
    end if;
    g_event_listeners_index.delete;
    g_listeners := t_listeners();
  end;

  procedure dispose_listeners is
  begin
    if g_suspended_event_managers is not null and g_suspended_event_managers.count > 0 then
      g_event_listeners_index :=  g_suspended_event_managers(g_suspended_event_managers.count).event_listener_index;
      g_listeners             :=  g_suspended_event_managers(g_suspended_event_managers.count).listeners;
      g_suspended_event_managers.trim(1);
    else
      g_event_listeners_index.delete;
      g_listeners := t_listeners();
    end if;
  end;

  procedure trigger_event( a_event_name t_event_name, a_event_object ut_event_item := null ) is

    procedure trigger_listener_event(
      a_listener_numbers t_listener_numbers,
      a_event_name t_event_name,
      a_event_object ut_event_item
    ) is
      l_listener_number t_listener_number := a_listener_numbers.first;
    begin
      while l_listener_number is not null loop
        g_listeners(l_listener_number).on_event(a_event_name, a_event_object);
        l_listener_number := a_listener_numbers.next(l_listener_number);
      end loop;
    end;
  begin
    if a_event_name is not null then
      if g_event_listeners_index.exists(gc_all) then
        trigger_listener_event( g_event_listeners_index(gc_all), a_event_name, a_event_object );
      end if;
      if g_event_listeners_index.exists(a_event_name) then
        trigger_listener_event( g_event_listeners_index(a_event_name), a_event_name, a_event_object );
      end if;
      if a_event_name = ut_event_manager.gc_finalize then
        dispose_listeners();
      end if;
    end if;
  end;

  procedure add_event( a_event_name t_event_name, a_listener_pos binary_integer ) is
  begin
    g_event_listeners_index(a_event_name)(a_listener_pos) := true;
  end;

  procedure add_events( a_event_names ut_varchar2_list, a_listener_pos binary_integer ) is
  begin
    for i in 1 .. a_event_names.count loop
      add_event( a_event_names(i), a_listener_pos );
    end loop;
  end;

  function add_listener( a_listener ut_event_listener ) return t_listener_number is
  begin
    if g_listeners is null then
      g_listeners := t_listeners();
    end if;
    g_listeners.extend;
    g_listeners(g_listeners.last) := a_listener;
    return g_listeners.last;
  end;

  procedure add_listener( a_listener ut_event_listener ) is
    l_event_names ut_varchar2_list;
  begin
    if a_listener is not null then
      l_event_names := a_listener.get_supported_events();
      if l_event_names is not empty then
        add_events( l_event_names, add_listener( a_listener ) );
      end if;
    end if;
  end;

end;
/
