create or replace type body ut_assertion_number as

  constructor function ut_assertion_number(self in out nocopy ut_assertion_number, a_actual number, a_message varchar2 default null) return self as result is
  begin
    self.data_type := 'number';
    self.message := a_message;
    self.actual := a_actual;
    self.actual_value_string := ut_utils.to_string(a_actual);
    self.is_null := ut_utils.boolean_to_int( (a_actual is null) );
    return;
  end;

  overriding member procedure to_be_equal(self in ut_assertion_number, a_expected number) is
  begin
    ut_utils.debug_log('ut_assertion_number.to_be_equal(self in ut_assertion, a_expected number)');
    self.build_assert_result( (a_expected = self.actual), 'to be equal', ut_utils.to_string(a_expected));
  end;

end;
/
