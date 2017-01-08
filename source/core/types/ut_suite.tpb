create or replace type body ut_suite as

  constructor function ut_suite(
    self in out nocopy ut_suite, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2, a_description varchar2 := null,
    a_path varchar2 := null, a_rollback_type integer := null, a_ignore_flag boolean := false, a_before_all_proc_name varchar2 := null,
    a_after_all_proc_name varchar2 := null, a_before_each_proc_name varchar2 := null, a_after_each_proc_name varchar2 := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name, a_description, a_path, a_rollback_type, a_ignore_flag);
    self.before_all := ut_executable(self, a_before_all_proc_name, ut_utils.gc_before_all);
    self.before_each := ut_executable(self, a_before_each_proc_name, ut_utils.gc_before_each);
    self.items := ut_suite_items();
    self.after_each := ut_executable(self, a_after_each_proc_name, ut_utils.gc_after_each);
    self.after_all := ut_executable(self, a_after_all_proc_name, ut_utils.gc_after_all);
    return;
  end;

  member function is_valid return boolean is
    l_is_valid boolean;
  begin
    l_is_valid :=
      ( not self.before_all.is_defined() or self.before_all.is_valid() ) and
      ( not self.before_each.is_defined() or self.before_each.is_valid() ) and
      ( not self.after_each.is_defined() or self.after_each.is_valid() ) and
      ( not self.after_all.is_defined() or self.after_all.is_valid() );
    return l_is_valid;
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

  member procedure add_item(self in out nocopy ut_suite, a_item ut_suite_item) is
  begin
    self.items.extend;
    self.items(self.items.last) := a_item;
  end;

  overriding member procedure do_execute(self in out nocopy ut_suite, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors boolean;
  begin
    l_completed_without_errors := self.do_execute(a_listener);
  end;

  overriding member function do_execute(self in out nocopy ut_suite, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_suite_savepoint varchar2(30);
    l_item_savepoint  varchar2(30);
    l_completed_without_errors boolean;
  begin
    ut_utils.debug_log('ut_suite.execute');

    if self.get_ignore_flag() then
      self.result := ut_utils.tr_ignore;
      ut_utils.debug_log('ut_suite.execute - ignored');
    else
      a_listener.fire_before_event(ut_utils.gc_suite,self);

      self.start_time := current_timestamp;

      l_suite_savepoint := self.create_savepoint_if_needed();

      --includes listener calls for before and after actions
      l_completed_without_errors := self.before_all.do_execute(self, a_listener);

      if l_completed_without_errors then
        for i in 1 .. self.items.count loop
          l_completed_without_errors := true;

          --savepoint
          l_item_savepoint := self.items(i).create_savepoint_if_needed();
          --before each
          if l_completed_without_errors then
            --includes listener calls for before and after actions
            l_completed_without_errors := self.before_each.do_execute(self, a_listener);
          end if;

          -- execute the item (test or suite)
          if l_completed_without_errors then
            l_completed_without_errors := self.items(i).do_execute(a_listener);
          end if;

          --after each
          if l_completed_without_errors then
            --includes listener calls for before and after actions
            l_completed_without_errors := self.after_each.do_execute(self, a_listener);
          end if;
          --rollback to savepoint
          self.items(i).rollback_to_savepoint(l_item_savepoint);

--          exit when not l_completed_without_errors;
        end loop;
      end if;

      if l_completed_without_errors then
        l_completed_without_errors := self.after_all.do_execute(self, a_listener);
      end if;

      self.calc_execution_result;

      self.rollback_to_savepoint(l_suite_savepoint);

      self.end_time := current_timestamp;

      a_listener.fire_after_event(ut_utils.gc_suite,self);
    end if;

    return l_completed_without_errors;
  end;

  member procedure calc_execution_result(self in out nocopy ut_suite) is
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
