create or replace type body ut_test_object is

  member procedure init(self in out nocopy ut_test_object, a_desc_name varchar2, a_object_name varchar2, a_object_type integer, a_object_path varchar2 default null, a_rollback_type integer default null) is
  begin
    self.name        := a_desc_name;
    self.object_type := a_object_type;
    self.object_name := lower(trim(a_object_name));
    self.object_path := nvl(lower(trim(a_object_path)), self.object_name);
  
    if a_rollback_type is not null then
      ut_utils.validate_rollback_type(a_rollback_type);
      self.rollback_type := a_rollback_type;
    else
      self.rollback_type := ut_utils.gc_rollback_auto;
    end if;
    return;
  end;
  
  member procedure set_ignore_flag(self in out nocopy ut_test_object, a_ignore_flag boolean) is
  begin
    self.ignore_flag := case a_ignore_flag when true then 1 else 0 end;
  end;
  member procedure set_rollback_type(self in out nocopy ut_test_object, a_rollback_type integer) is
  begin
    ut_utils.validate_rollback_type(a_rollback_type => a_rollback_type);
    
    self.rollback_type := a_rollback_type;
  end;

  member function execution_time return number is
    l_sec number;
  begin
    l_sec := extract(day from(end_time - start_time)) * 24 * 60 * 60 +
             extract(hour from(end_time - start_time)) * 60 * 60 + extract(minute from(end_time - start_time)) * 60 +
             extract(second from(end_time - start_time));
    return l_sec;
  end;

  final member procedure do_execute(self in out nocopy ut_test_object) is
    l_null_reporter ut_reporter := ut_reporter();
  begin
    self.do_execute(l_null_reporter);
  end;


end;
/
