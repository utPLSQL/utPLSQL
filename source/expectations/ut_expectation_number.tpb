create or replace type body ut_expectation_number as

  overriding member procedure to_equal(self in ut_expectation_number, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_number.to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;
  
  member procedure to_be_between(self in ut_expectation_number, a_lower_bound number, a_higher_bound number) is
  begin
    ut_utils.debug_log('ut_expectation_number.to_be_between(self in ut_expectation_date, a_lower_bound number, a_higher_bound number)');
    self.to_( be_between(a_lower_bound,a_higher_bound) );
  end;

end;
/
