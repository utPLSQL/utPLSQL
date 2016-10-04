create or replace type body ut_assertion_varchar as

  constructor function ut_assertion_varchar(self in out nocopy ut_assertion_varchar, a_message varchar2 default null, a_actual varchar2) return self as result is
  begin
    self.a_data_type := 'varchar2';
    self.a_message := a_message;
    self.a_actual_value_string := ut_utils.to_string(a_actual);
  end;

--  constructor function ut_assertion_varchar(self in out nocopy ut_assertion_varchar, a_actual varchar2) return self as result is
--  begin
--    self.a_data_type := 'varchar2';
--    self.a_actual := a_actual;
--  end;

  member procedure to_be_equal(a_expected varchar2) is
  begin
    self.build_assert_result( (a_expected = self.a_actual), 'to_be_equal', ut_utils.to_string(a_expected));
  end;

  member procedure to_be_like(a_mask in varchar, a_escape_char in varchar2 := null) is
    l_condition boolean;
    l_escape_msg varchar2(100) := case when a_escape_char is not null then ' using escape '||a_escape_char end;
  begin
    if a_escape_char is not null then
      l_condition := self.a_actual like a_mask escape a_escape_char;
    else
      l_condition := self.a_actual like a_mask;
    end if;
    self.build_assert_result(l_condition, 'to_be_like', ut_utils.to_string(a_mask)||l_escape_msg, ut_utils.to_string(l_condition));
  end;

  member procedure to_be_matching(a_pattern in varchar2, a_modifier in varchar2 default null) is
  begin
    null;
  end;

  member procedure to_be_null is
  begin
    self.build_assert_result(self.a_actual is null, 'to_be_null', null, ut_utils.to_string(to_char(null)));
  end;

  member procedure to_be_not_null is
  begin
    self.build_assert_result(self.a_actual is not null, 'to_be_not_null', null, ut_utils.to_string(to_char(null)));
  end;
end;
/
