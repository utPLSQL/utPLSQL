create or replace type body ut_expectation_refcursor as

  overriding member procedure to_equal(self in ut_expectation_refcursor, a_expected sys_refcursor, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_refcursor.to_equal(self in ut_expectation_refcursor, a_expected sys_refcursor, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
