create or replace type body ut_expectation_blob as

  overriding member procedure to_equal(self in ut_expectation_blob, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_blob.to_equal(self in ut_expectation, a_expected blob)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
