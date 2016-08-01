create or replace type body ut_assert_result is

  constructor function ut_assert_result(a_result varchar2, a_message varchar2, a_name varchar2 default null)
    return self as result is
  begin
    self.name        := a_name;
    self.object_type := 0;
    self.result      := a_result;
    self.message     := a_message;
    return;
  end ut_assert_result;

end;
/
