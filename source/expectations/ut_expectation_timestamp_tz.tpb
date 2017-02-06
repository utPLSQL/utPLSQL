create or replace type body ut_expectation_timestamp_tz as

  overriding member procedure to_equal(self in ut_expectation_timestamp_tz, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_timestamp_tz.to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_between(self in ut_expectation_timestamp_tz, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained) is
  begin
    ut_utils.debug_log('ut_expectation_timestamp_tz.to_be_between(self in ut_expectation_timestamp_tz, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)');
    self.to_( ut_be_between(a_lower_bound, a_upper_bound) );
  end;

end;
/
