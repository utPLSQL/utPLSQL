create or replace type body ut_expectation_timestamp as

  overriding member procedure to_equal(self in ut_expectation_timestamp, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_timestamp.to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;
  
  member procedure to_be_between(self in ut_expectation_timestamp, a_lower_bound timestamp_unconstrained, a_higher_bound timestamp_unconstrained) is
  begin
    ut_utils.debug_log('ut_expectation_timestamp.to_be_between(self in ut_expectation_timestamp, a_lower_bound timestamp_unconstrained, a_higher_bound timestamp_unconstrained)');
    self.to_( be_between(a_lower_bound, a_higher_bound) );
  end;

end;
/
