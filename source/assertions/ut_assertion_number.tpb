create or replace type body ut_assertion_number as

  overriding member procedure to_equal(self in ut_assertion_number, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_number.to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
