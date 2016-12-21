create or replace type body ut_expectation_dsinterval as

  overriding member procedure to_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_dsinterval.to_equal(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;
end;
/
