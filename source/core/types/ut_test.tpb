create or replace type body ut_test as
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

  constructor function ut_test(
    self in out nocopy ut_test, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2, a_description varchar2 := null,
    a_path varchar2 := null, a_rollback_type integer := null, a_ignore_flag boolean := false, a_before_test_proc_name varchar2 := null, a_after_test_proc_name varchar2 := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name, a_description, a_path, a_rollback_type, a_ignore_flag);
    self.before_test := ut_executable(self, a_before_test_proc_name, ut_utils.gc_before_test);
    self.item := ut_executable(self, a_name, ut_utils.gc_test_execute);
    self.after_test := ut_executable(self, a_after_test_proc_name, ut_utils.gc_after_test);
    return;
  end;

  member function is_valid return boolean is
    l_is_valid boolean;
  begin
    l_is_valid :=
      ( not self.before_test.is_defined() or self.before_test.is_valid() ) and
      ( self.item.is_valid()  ) and
      ( not self.after_test.is_defined() or self.after_test.is_valid() );
    return l_is_valid;
  end;

  overriding member function do_execute(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_completed_without_errors boolean;
    l_savepoint                varchar2(30);
  begin

    ut_utils.debug_log('ut_test.execute');

    a_listener.fire_before_event(ut_utils.gc_test,self);
    self.start_time := current_timestamp;

    if self.get_ignore_flag() then
      self.result := ut_utils.tr_ignore;
      ut_utils.debug_log('ut_test.execute - ignored');
      self.results_count := ut_results_counter(self.result);
      self.end_time := self.start_time;
    else
      if self.is_valid() then

        l_savepoint := self.create_savepoint_if_needed();

        --includes listener calls for before and after actions
        l_completed_without_errors := self.before_test.do_execute(self, a_listener);

        if l_completed_without_errors then
          l_completed_without_errors := self.item.do_execute(self, a_listener);
        end if;

        if l_completed_without_errors then
          l_completed_without_errors := self.after_test.do_execute(self, a_listener);
        end if;

        self.rollback_to_savepoint(l_savepoint);

      end if;
      self.calc_execution_result();
      self.end_time := current_timestamp;
    end if;
    a_listener.fire_after_event(ut_utils.gc_test,self);
    return l_completed_without_errors;
  end;

  overriding member procedure calc_execution_result(self in out nocopy ut_test) is
  begin
    self.result := ut_assert_processor.get_aggregate_asserts_result();
    --expectation results need to be part of test results
    self.results := ut_assert_processor.get_asserts_results();
    self.results_count := ut_results_counter(self.result);
  end;
  
  overriding member procedure fail(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base, a_failure_msg varchar2) is
  begin
    ut_utils.debug_log('ut_test.fail');
    a_listener.fire_before_event(ut_utils.gc_test, self);
    self.start_time := current_timestamp;
    ut_assert_processor.report_error(a_failure_msg);
    self.calc_execution_result();
    self.end_time := self.start_time;
    a_listener.fire_after_event(ut_utils.gc_test, self);
  end;
 

end;
/
