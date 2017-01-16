create or replace type body ut_logical_suite as

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

  overriding member procedure do_execute(self in out nocopy ut_logical_suite, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors boolean;
  begin
    l_completed_without_errors := self.do_execute(a_listener);
  end;

  overriding member function do_execute(self in out nocopy ut_logical_suite, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_suite_savepoint varchar2(30);
    l_item_savepoint  varchar2(30);
    l_completed_without_errors boolean;
  begin
    ut_utils.debug_log('ut_logical_suite.execute');

    if self.get_ignore_flag() then
      self.result := ut_utils.tr_ignore;
      ut_utils.debug_log('ut_logical_suite.execute - ignored');
    else
      a_listener.fire_before_event(ut_utils.gc_suite,self);

      self.start_time := current_timestamp;

      for i in 1 .. self.items.count loop
        -- execute the item (test or suite)
        self.items(i).do_execute(a_listener);

      end loop;

      self.calc_execution_result();

      self.end_time := current_timestamp;

      a_listener.fire_after_event(ut_utils.gc_suite,self);
    end if;

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
