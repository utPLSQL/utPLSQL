create or replace type body ut_expectation_date as

  overriding member procedure to_equal(self in ut_expectation_date, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_date.to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_between(self in ut_expectation_date, a_lower_bound date, a_upper_bound date) is
  begin
    ut_utils.debug_log('ut_expectation_date.to_be_between(self in ut_expectation_date, a_lower_bound date, a_upper_bound date)');
    self.to_( ut_be_between(a_lower_bound,a_upper_bound) );
  end;

end;
/
