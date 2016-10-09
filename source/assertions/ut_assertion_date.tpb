create or replace type body ut_assertion_date as

  constructor function ut_assertion_date(self in out nocopy ut_assertion_date, a_actual date, a_message varchar2 default null) return self as result is
  begin
    self.message := a_message;
    self.actual_data := ut_data_value_date('date', ut_utils.boolean_to_int( (a_actual is null) ), ut_utils.to_string(a_actual), a_actual);
    return;
  end;

  overriding member procedure to_equal(self in ut_assertion_date, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_date.to_equal(self in ut_assertion, a_expected date, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
