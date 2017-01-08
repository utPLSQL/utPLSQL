create or replace type body ut_run as

  constructor function ut_run( self in out nocopy ut_run, a_items ut_suite_items ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.items := a_items;
    return;
  end;

  overriding member procedure do_execute(self in out nocopy ut_run, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors boolean;
  begin
    l_completed_without_errors := self.do_execute(a_listener);
  end;

  overriding member function do_execute(self in out nocopy ut_run, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_completed_without_errors boolean;
  begin
    ut_utils.debug_log('ut_run.execute');

    a_listener.fire_before_event(ut_utils.gc_run, self);

    self.start_time := current_timestamp;

    for i in 1 .. self.items.count loop
      l_completed_without_errors := self.items(i).do_execute(a_listener);
    end loop;

    self.calc_execution_result;

    self.end_time := current_timestamp;

    a_listener.fire_after_event(ut_utils.gc_run, self);

    return l_completed_without_errors;
  end;

  member procedure calc_execution_result(self in out nocopy ut_run) is
    l_result integer(1);
  begin
    if self.items is not null and self.items.count > 0 then
      l_result := ut_utils.tr_ignore;
      for i in 1 .. self.items.count loop
        l_result := greatest(self.items(i).result, l_result);
        exit when l_result = ut_utils.tr_error;
      end loop;
    else
      l_result := ut_utils.tr_success;
    end if;

    self.result := l_result;
  end;

end;
/
