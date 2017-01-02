create or replace type body ut_suite_item as

  member procedure init(
    self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2,
    a_description varchar2, a_path varchar2, a_rollback_type integer, a_ignore_flag boolean
  ) is
  begin
    self.object_owner := a_object_owner;
    self.object_name := lower(trim(a_object_name));
    self.name := lower(trim(a_name));
    self.description := a_description;
    self.path := nvl(lower(trim(a_path)), self.object_name);
    self.rollback_type := a_rollback_type;
    self.ignore_flag := ut_utils.boolean_to_int(a_ignore_flag);
  end;

  member procedure set_ignore_flag( self in out nocopy ut_suite_item, a_ignore_flag boolean) is
  begin
    self.ignore_flag := ut_utils.boolean_to_int(a_ignore_flag);
  end;

  member function get_ignore_flag return boolean is
  begin
    return ut_utils.int_to_boolean(self.ignore_flag);
  end;

  member function create_savepoint_if_needed return varchar2 is
    l_savepoint varchar2(30);
  begin
    if self.rollback_type = ut_utils.gc_rollback_auto then
      l_savepoint := ut_utils.gen_savepoint_name();
      execute immediate 'savepoint ' || l_savepoint;
    end if;
    return l_savepoint;
  end;

  member procedure rollback_to_savepoint( self in ut_suite_item, a_savepoint varchar2) is
  begin
    if self.rollback_type = ut_utils.gc_rollback_auto and a_savepoint is not null then
      execute immediate 'rollback to ' || a_savepoint;
    end if;
  end;

  member function execution_time return number is
  begin
    return ut_utils.time_diff(start_time, end_time);
  end;

end;
/