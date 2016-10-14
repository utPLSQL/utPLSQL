create or replace type body ut_test_object is
  
  member procedure set_ignore_flag(self in out nocopy ut_test_object, a_ignore_flag boolean) is
  begin
    
    self.ignore_flag := case a_ignore_flag when true then 1 else 0 end;
  end;
  member procedure set_rollback_type(self in out nocopy ut_test_object, a_rollback_type integer) is
  begin
    ut_utils.validate_rollback_type(a_rollback_type => a_rollback_type);
    
    self.rollback_type := a_rollback_type;
  end;
  
end;
/
