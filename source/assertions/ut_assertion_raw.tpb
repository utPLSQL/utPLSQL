create or replace type body ut_assertion_raw as

  constructor function ut_assertion_raw(self in out nocopy ut_assertion_raw, a_actual raw, a_message varchar2 default null) return self as result is
  begin
    self.data_type := 'raw';
    self.message := a_message;
    self.actual_value_string := ut_utils.to_string(a_actual);
    self.is_null := ut_utils.boolean_to_int( (a_actual is null) );
    return;
  end;

  overriding member procedure to_be_equal(self in ut_assertion_raw, a_expected raw) is
  begin
    self.build_assert_result( (a_expected = self.actual), 'to be equal', ut_utils.to_string(a_expected));
  end;

end;
/
