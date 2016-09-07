create or replace type body ut_assert_result is

  constructor function ut_assert_result(a_result integer, a_message varchar2, a_name varchar2 default null)
    return self as result is
  begin
    self.name        := a_name;
    self.object_type := 0;
    self.result      := a_result;
    self.message     := a_message;
    return;
  end ut_assert_result;

  constructor function ut_assert_result(a_name varchar2, a_result integer, a_expected_type varchar2, a_actual_type varchar2,
    a_expected_value_string varchar2, a_actual_value_string varchar2, a_message varchar2 default null)
    return self as result is
  begin
    self.name                  := a_name;
    self.object_type           := 0;
    self.result                := a_result;
    self.message               := a_message;
    self.expected_type         := a_expected_type;
    self.actual_type           := a_actual_type;
    self.expected_value_string := a_expected_value_string;
    self.actual_value_string   := a_actual_value_string;
    return;
  end ut_assert_result;

end;
/
