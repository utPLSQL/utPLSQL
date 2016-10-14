create or replace type body ut_assertion_anydata as

  overriding member procedure to_equal(self in ut_assertion_anydata, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_anydata.to_equal(self in ut_assertion_anydata, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
