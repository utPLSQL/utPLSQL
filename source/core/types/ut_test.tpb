create or replace type body ut_test as
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

  constructor function ut_test(
    self in out nocopy ut_test, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2,
    a_line_no integer, a_expected_error_codes ut_integer_list := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name, a_line_no);
    self.item := ut_executable_test(a_object_owner, a_object_name, a_name, ut_utils.gc_test_execute);
    self.before_each_list     := ut_executables();
    self.before_test_list     := ut_executables();
    self.after_test_list      := ut_executables();
    self.after_each_list      := ut_executables();
    self.all_expectations     := ut_expectation_results();
    self.failed_expectations  := ut_expectation_results();
    self.expected_error_codes := a_expected_error_codes;
    return;
  end;

  overriding member procedure mark_as_skipped(self in out nocopy ut_test) is
  begin
    ut_event_manager.trigger_event(ut_utils.gc_before_test, self);
    self.start_time := current_timestamp;
    self.result := ut_utils.gc_disabled;
    ut_utils.debug_log('ut_test.execute - disabled');
    self.results_count.set_counter_values(self.result);
    self.end_time := self.start_time;
    ut_event_manager.trigger_event(ut_utils.gc_after_test, self);
  end;

  overriding member function do_execute(self in out nocopy ut_test) return boolean is
    l_no_errors boolean;
    l_savepoint varchar2(30);
  begin

    ut_utils.debug_log('ut_test.execute');

    if self.get_disabled_flag() then
      mark_as_skipped();
    else
      ut_event_manager.trigger_event(ut_utils.gc_before_test, self);
      self.start_time := current_timestamp;

      l_savepoint := self.create_savepoint_if_needed();

      --includes listener calls for before and after actions
      l_no_errors := true;
      for i in 1 .. self.before_each_list.count loop
        l_no_errors := self.before_each_list(i).do_execute(self);
        exit when not l_no_errors;
      end loop;

      if l_no_errors then
        for i in 1 .. self.before_test_list.count loop
          l_no_errors := self.before_test_list(i).do_execute(self);
          exit when not l_no_errors;
        end loop;

        if l_no_errors then
          -- execute the test
          self.item.do_execute(self, self.expected_error_codes);

        end if;
        -- perform cleanup regardless of the test or setup failure
        for i in 1 .. self.after_test_list.count loop
          self.after_test_list(i).do_execute(self);
        end loop;
      end if;

      for i in 1 .. self.after_each_list.count loop
        self.after_each_list(i).do_execute(self);
      end loop;
      self.rollback_to_savepoint(l_savepoint);

      self.calc_execution_result();
      self.end_time := current_timestamp;
      ut_event_manager.trigger_event(ut_utils.gc_after_test, self);
    end if;
    return l_no_errors;
  end;

  overriding member procedure calc_execution_result(self in out nocopy ut_test) is
    l_warnings ut_varchar2_rows;
  begin
    if self.get_error_stack_traces().count = 0 then
      self.result := ut_expectation_processor.get_status();
    else
      self.result := ut_utils.gc_error;
    end if;
    --expectation results need to be part of test results
    self.all_expectations    := ut_expectation_processor.get_all_expectations();
    self.failed_expectations := ut_expectation_processor.get_failed_expectations();
    l_warnings := coalesce( ut_expectation_processor.get_warnings(), ut_varchar2_rows() );
    self.warnings := self.warnings multiset union all l_warnings;
    self.results_count.increase_warning_count( cardinality(l_warnings) );
    self.results_count.set_counter_values(self.result);
    ut_expectation_processor.clear_expectations();
  end;

  overriding member procedure mark_as_errored(self in out nocopy ut_test, a_error_stack_trace varchar2) is
  begin
    ut_utils.debug_log('ut_test.fail');
    ut_event_manager.trigger_event(ut_utils.gc_before_test, self);
    self.start_time := current_timestamp;
    self.parent_error_stack_trace := a_error_stack_trace;
    self.calc_execution_result();
    self.end_time := self.start_time;
    ut_event_manager.trigger_event(ut_utils.gc_after_test, self);
  end;

  overriding member function get_error_stack_traces(self ut_test) return ut_varchar2_list is
    l_stack_traces ut_varchar2_list := ut_varchar2_list();
  begin
    ut_utils.append_to_list(l_stack_traces, self.parent_error_stack_trace);
    for i in 1 .. before_each_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.before_each_list(i).get_error_stack_trace());
    end loop;
    for i in 1 .. before_test_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.before_test_list(i).get_error_stack_trace());
    end loop;
    ut_utils.append_to_list(l_stack_traces, self.item.get_error_stack_trace());
    for i in 1 .. after_test_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.after_test_list(i).get_error_stack_trace());
    end loop;
    for i in 1 .. after_each_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.after_each_list(i).get_error_stack_trace());
    end loop;
    return l_stack_traces;
  end;
  overriding member function get_serveroutputs return clob is
    l_outputs clob;
  begin
    for i in 1 .. before_each_list.count loop
      ut_utils.append_to_clob(l_outputs, self.before_each_list(i).serveroutput);
    end loop;
    for i in 1 .. before_test_list.count loop
      ut_utils.append_to_clob(l_outputs, self.before_test_list(i).serveroutput);
    end loop;
    ut_utils.append_to_clob(l_outputs, self.item.serveroutput );
    for i in 1 .. after_test_list.count loop
      ut_utils.append_to_clob(l_outputs, self.after_test_list(i).serveroutput);
    end loop;
    for i in 1 .. after_each_list.count loop
      ut_utils.append_to_clob(l_outputs, self.after_each_list(i).serveroutput);
    end loop;
    return l_outputs;
  end;
end;
/
