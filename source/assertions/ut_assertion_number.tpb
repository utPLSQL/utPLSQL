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

  overriding member procedure to_equal(self in ut_assertion_number, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_number.to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null)');
    self.build_assert_result(
      (   (a_expected is null and self.actual is null and coalesce(a_nulls_are_equal, ut_assert_processor.nulls_are_equal()))
       or (a_expected = self.actual)) , 'to equal', ut_utils.to_string(a_expected)
    );
  end;

end;
/
