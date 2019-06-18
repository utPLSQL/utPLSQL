create or replace type body ut_debug_reporter is
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

  constructor function ut_debug_reporter(self in out nocopy ut_debug_reporter) return self as result is
  begin
    self.init($$plsql_unit,ut_output_clob_table_buffer());
    self.start_time := current_timestamp();
    self.event_time := current_timestamp();
    return;
  end;
    
  overriding member function get_supported_events return ut_varchar2_list is
  begin
    return ut_varchar2_list(ut_event_manager.gc_all);
  end;

  overriding member procedure on_event( self in out nocopy ut_debug_reporter, a_event_name varchar2, a_event_item ut_event_item) is
    c_time            constant timestamp := current_timestamp();
    c_time_from_start constant interval day(0) to second(6) := (c_time - self.start_time);
    c_time_from_prev  constant interval day(0) to second(6) := (c_time - self.event_time);
    l_stack varchar2(32767) := dbms_utility.format_call_stack();
    begin
    l_stack := regexp_replace(
      substr( l_stack, instr( l_stack, chr(10), 1, 6 ) +1 ),
      '[0-9abcdefx]+ +([0-9]+) +(package |type )?(body )?(.*)','at "\4", line \1');

    if a_event_name = ut_event_manager.gc_initialize then
      self.on_initialize(null);
      self.print_text('<DEBUG_LOG>', ut_event_manager.gc_debug);
    end if;
    self.print_text('<DEBUG>', ut_event_manager.gc_debug);
    self.print_text(
      '  <TIMESTAMP>' || ut_utils.to_string(c_time) || '</TIMESTAMP>' || chr(10)
        || '  <TIME_FROM_START>'  || c_time_from_start || '</TIME_FROM_START>' || chr(10)
        || '  <TIME_FROM_PREVIOUS>'  || c_time_from_prev || '</TIME_FROM_PREVIOUS>' || chr(10)
        || '  <EVENT_NAME>' || a_event_name || '</EVENT_NAME>',
      ut_event_manager.gc_debug
    );
    self.print_text( '  <CALL_STACK>' || l_stack || '</CALL_STACK>', ut_event_manager.gc_debug);
    if a_event_item is not null then
      self.print_text_lines(
        ut_utils.convert_collection(
          ut_utils.clob_to_table( event_item_to_clob(a_event_item), ut_utils.gc_max_storage_varchar2_len )
        ),
        ut_event_manager.gc_debug
      );
    end if;
    self.print_text('</DEBUG>', ut_event_manager.gc_debug);
    if a_event_name = ut_event_manager.gc_finalize then
      self.print_text('</DEBUG_LOG>', ut_event_manager.gc_debug);
      self.on_finalize(null);
    end if;
    self.event_time := current_timestamp();
  end;

  member function event_item_to_clob(a_event_item ut_event_item) return clob is
    l_clob clob;
  begin
    select xmlserialize( content deletexml(xmltype(a_event_item),'/*/ITEMS|/*/ALL_EXPECTATIONS|/*/FAILED_EXPECTATIONS') as clob indent size = 2 ) into l_clob from dual;
    return l_clob;
  end;

end;
/