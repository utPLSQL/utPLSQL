create or replace type body ut_suite  as
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

  constructor function ut_suite (
    self in out nocopy ut_suite, a_object_owner varchar2, a_object_name varchar2, a_line_no integer,
    a_tags varchar2 := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_object_name, a_line_no);
    self.items := ut_suite_items();
    before_all_list := ut_executables();
    after_all_list  := ut_executables();
    self.tags       := a_tags;
    return;
  end;

  overriding member function do_execute(self in out nocopy ut_suite) return boolean is
    l_suite_savepoint varchar2(30);
    l_no_errors boolean;

    procedure propagate_error(a_error_stack_trace varchar2) is
    begin
      for i in 1..self.items.count loop
        self.items(i).mark_as_errored(a_error_stack_trace);
      end loop;
    end;
  begin
    ut_utils.debug_log('ut_suite.execute');

    ut_utils.set_action(self.object_name);

    if self.get_disabled_flag() then
      self.mark_as_skipped();
    else
      ut_event_manager.trigger_event(ut_event_manager.gc_before_suite, self);
      self.start_time := current_timestamp;

      l_suite_savepoint := self.create_savepoint_if_needed();

      --includes listener calls for before and after actions
      l_no_errors := true;
      for i in 1 .. self.before_all_list.count loop
        l_no_errors := self.before_all_list(i).do_execute(self);
        if not l_no_errors then
          propagate_error(self.before_all_list(i).get_error_stack_trace());
          exit;
        end if;
      end loop;

      if l_no_errors then
        for i in 1 .. self.items.count loop
          self.items(i).do_execute();
        end loop;
      end if;

      for i in 1 .. after_all_list.count loop
        l_no_errors := self.after_all_list(i).do_execute(self);
        if not l_no_errors then
          self.put_warning(self.after_all_list(i).get_error_stack_trace());
        end if;
      end loop;

      self.rollback_to_savepoint(l_suite_savepoint);

      self.calc_execution_result();
      self.end_time := current_timestamp;
      ut_event_manager.trigger_event(ut_event_manager.gc_after_suite, self);
    end if;

    ut_utils.set_action(null);

    return l_no_errors;
  end;

  overriding member function get_error_stack_traces(self ut_suite) return ut_varchar2_list is
    l_stack_traces ut_varchar2_list := ut_varchar2_list();
  begin
    for i in 1 .. before_all_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.before_all_list(i).get_error_stack_trace());
    end loop;
    for i in 1 .. after_all_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.after_all_list(i).get_error_stack_trace());
    end loop;
    return l_stack_traces;
  end;

  overriding member function get_serveroutputs return clob is
    l_outputs clob;
  begin
    for i in 1 .. before_all_list.count loop
      ut_utils.append_to_clob(l_outputs, self.before_all_list(i).serveroutput);
    end loop;
    for i in 1 .. after_all_list.count loop
      ut_utils.append_to_clob(l_outputs, self.after_all_list(i).serveroutput);
    end loop;
    return l_outputs;
  end;

end;
/
