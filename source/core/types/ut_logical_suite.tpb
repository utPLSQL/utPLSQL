create or replace type body ut_logical_suite as
  /*
  utPLSQL - Version X.X.X.X
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

  constructor function ut_logical_suite(
    self in out nocopy ut_logical_suite,a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_description varchar2 := null, a_path varchar2
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name, a_description, a_path, ut_utils.gc_rollback_auto, false);
    self.items := ut_suite_items();
    return;
  end;

  member function is_valid return boolean is
  begin
    return true;
  end;

  member function item_index(a_name varchar2) return pls_integer is
    l_item_index   pls_integer := self.items.first;
    c_lowered_name constant varchar2(4000 char) := lower(trim(a_name));
    l_result       pls_integer;
  begin
    while l_item_index is not null loop
      if self.items(l_item_index).name = c_lowered_name then
        l_result := l_item_index;
        exit;
      end if;
      l_item_index := self.items.next(l_item_index);
    end loop;
    return l_result;
  end item_index;

  member procedure add_item(self in out nocopy ut_logical_suite, a_item ut_suite_item) is
  begin
    self.items.extend;
    self.items(self.items.last) := a_item;
  end;

  overriding member function do_execute(self in out nocopy ut_logical_suite, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_suite_savepoint varchar2(30);
    l_item_savepoint  varchar2(30);
    l_completed_without_errors boolean;
  begin
    ut_utils.debug_log('ut_logical_suite.execute');
    
    a_listener.fire_before_event(ut_utils.gc_suite,self);   
    self.start_time := current_timestamp; 

    if self.get_ignore_flag() then
      self.result := ut_utils.tr_ignore;
      self.end_time := self.start_time;
      ut_utils.debug_log('ut_logical_suite.execute - ignored');
    else

      self.start_time := current_timestamp;

      for i in 1 .. self.items.count loop
        -- execute the item (test or suite)
        self.items(i).do_execute(a_listener);
      end loop;

      self.calc_execution_result();
      self.end_time := current_timestamp;

    end if;
    
    a_listener.fire_after_event(ut_utils.gc_suite,self);

    return l_completed_without_errors;
  end;

  overriding member procedure calc_execution_result(self in out nocopy ut_logical_suite) is
    l_result integer(1);
  begin
    if self.items is not null and self.items.count > 0 then
      for i in 1 .. self.items.count loop
        self.results_count.sum_counter_values( self.items(i).results_count );
      end loop;
      l_result := self.results_count.result_status();
    else
      --if suite is empty then it's successful (no errors)
      l_result := ut_utils.tr_success;
    end if;

      self.result := l_result;
    end;

end;
/
