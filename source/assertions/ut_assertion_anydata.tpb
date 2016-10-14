create or replace type body ut_assertion_refcursor as

  overriding member procedure to_equal(self in ut_assertion_refcursor, a_expected sys_refcursor, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_refcursor.to_equal(self in ut_assertion_refcursor, a_expected sys_refcursor, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
