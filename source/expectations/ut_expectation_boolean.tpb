create or replace type body ut_expectation_boolean as

  overriding member procedure to_equal(self in ut_expectation_boolean, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_boolean.to_equal(self in ut_expectation_boolean, a_expected boolean, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_true(self in ut_expectation_boolean) is
  begin
    ut_utils.debug_log('ut_expectation_boolean.to_be_true(self in ut_expectation_boolean)');
    self.to_( be_true() );
  end;

  member procedure to_be_false(self in ut_expectation_boolean) is
  begin
    ut_utils.debug_log('ut_expectation_boolean.to_be_false(self in ut_expectation_boolean)');
    self.to_( be_false() );
  end;

end;
/
