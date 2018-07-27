create or replace type body ut_logical_suite as
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

  constructor function ut_logical_suite(
    self in out nocopy ut_logical_suite,a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_path varchar2
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name);
    self.path := a_path;
    self.disabled_flag := ut_utils.boolean_to_int(false);
    self.items := ut_suite_items();
    return;
  end;

  member function is_valid(self in out nocopy ut_logical_suite) return boolean is
  begin
    return true;
  end;

  member procedure add_item(self in out nocopy ut_logical_suite, a_item ut_suite_item) is
  begin
    self.items.extend;
    self.items(self.items.last) := a_item;
  end;

  overriding member procedure mark_as_skipped(self in out nocopy ut_logical_suite) is
  begin
    ut_event_manager.trigger_event(ut_utils.gc_before_suite, self);
    self.start_time := current_timestamp;
    for i in 1 .. self.items.count loop
      self.items(i).mark_as_skipped();
    end loop;
    self.end_time := self.start_time;
    ut_event_manager.trigger_event(ut_utils.gc_after_suite, self);
    self.calc_execution_result();
  end;

  overriding member procedure set_rollback_type(self in out nocopy ut_logical_suite, a_rollback_type integer) is
  begin
    self.rollback_type := coalesce(self.rollback_type, a_rollback_type);
    for i in 1 .. self.items.count loop
      self.items(i).set_rollback_type(self.rollback_type);
    end loop;
  end;

  overriding member function do_execute(self in out nocopy ut_logical_suite) return boolean is
    l_suite_savepoint varchar2(30);
    l_item_savepoint  varchar2(30);
    l_completed_without_errors boolean;
  begin
    ut_utils.debug_log('ut_logical_suite.execute');

    ut_event_manager.trigger_event(ut_utils.gc_before_suite, self);
    self.start_time := current_timestamp;

    for i in 1 .. self.items.count loop
      -- execute the item (test or suite)
      self.items(i).do_execute();
    end loop;

    self.calc_execution_result();
    self.end_time := current_timestamp;

    ut_event_manager.trigger_event(ut_utils.gc_after_suite, self);

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
      l_result := ut_utils.gc_success;
    end if;

      self.result := l_result;
  end;

  overriding member procedure mark_as_errored(self in out nocopy ut_logical_suite, a_error_stack_trace varchar2) is
  begin
    ut_utils.debug_log('ut_logical_suite.fail');
    ut_event_manager.trigger_event(ut_utils.gc_before_suite, self);
    self.start_time := current_timestamp;
    for i in 1 .. self.items.count loop
      -- execute the item (test or suite)
      self.items(i).mark_as_errored(a_error_stack_trace);
    end loop;
    self.calc_execution_result();
    self.end_time := self.start_time;
    ut_event_manager.trigger_event(ut_utils.gc_after_suite, self);
  end;

  overriding member function get_error_stack_traces return ut_varchar2_list is
  begin
    return ut_varchar2_list();
  end;

  overriding member function get_serveroutputs return clob is
  begin
    return null;
  end;

  overriding member function get_transaction_invalidators return ut_varchar2_list is
    l_result ut_varchar2_list;
    l_child_results ut_varchar2_list;
  begin
    l_result := self.transaction_invalidators;
    for i in 1 .. self.items.count loop
      l_child_results := self.items(i).get_transaction_invalidators();
      for j in 1 .. l_child_results.count loop
        if l_child_results(j) not member of l_result then
          l_result.extend; l_result(l_result.last) := l_child_results(j);
        end if;
      end loop;
    end loop;
    return l_result;
  end;

end;
/
