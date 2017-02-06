create or replace type body ut_test as

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

  overriding member procedure do_execute(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors boolean;
  begin
    l_completed_without_errors := self.do_execute(a_listener);
  end;

  overriding member function do_execute(self in out nocopy ut_test, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_completed_without_errors boolean;
    l_savepoint                varchar2(30);
  begin

    ut_utils.debug_log('ut_test.execute');

    if self.get_ignore_flag() then
      self.result := ut_utils.tr_ignore;
      ut_utils.debug_log('ut_test.execute - ignored');
      self.start_time := current_timestamp;
      self.end_time := current_timestamp;
    else

      a_listener.fire_before_event(ut_utils.gc_test,self);

      if self.is_valid() then

        self.start_time := current_timestamp;

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
      a_listener.fire_after_event(ut_utils.gc_test,self);

    end if;
    return l_completed_without_errors;
  end;

  overriding member procedure calc_execution_result(self in out nocopy ut_test) is
  begin
    self.result := ut_assert_processor.get_aggregate_asserts_result();
    --expectation results need to be part of test results
    self.results := ut_assert_processor.get_asserts_results();
    self.results_count := ut_results_counter(self.result);
  end;

end;
/
