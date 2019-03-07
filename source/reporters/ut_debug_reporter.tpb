create or replace type body ut_debug_reporter is
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

  constructor function ut_debug_reporter(self in out nocopy ut_debug_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;
    
  overriding member function get_supported_events return ut_varchar2_list is
  begin
    return ut_varchar2_list(ut_event_manager.gc_all);
  end;

  overriding member procedure on_event( self in out nocopy ut_debug_reporter, a_event_name varchar2, a_event_item ut_event_item) is
  begin
    if a_event_name = ut_event_manager.gc_initialize then
      self.on_initialize(null);
    end if;
    if a_event_item is not null then
      self.print_clob(
        to_clob( '<DEBUG><EVENT_NAME>' || a_event_name || '</EVENT_NAME>' || chr(10) )
          || a_event_item.to_clob()
          || to_clob('</DEBUG>'),
        ut_event_manager.gc_debug
      );
    else
      self.print_clob(
        '<DEBUG><EVENT_NAME>' || a_event_name || '</EVENT_NAME>' || chr(10) || '</DEBUG>',
        ut_event_manager.gc_debug
        );
    end if;
    if a_event_name = ut_event_manager.gc_finalize then
      self.on_finalize(null);
    end if;
  end;

end;
/