create or replace type body ut_expectation_anydata as

  overriding member procedure to_equal(self in ut_expectation_anydata, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_anydata.to_equal(self in ut_expectation_anydata, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
