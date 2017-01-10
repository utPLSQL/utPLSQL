create or replace type body ut_expectation_yminterval as

  overriding member procedure to_equal(self in ut_expectation_yminterval, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_yminterval.to_equal(self in ut_expectation, a_expected yminterval_unconstrained)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;
end;
/
