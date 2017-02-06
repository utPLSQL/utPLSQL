create or replace type body ut_expectation_varchar2 as

  overriding member procedure to_equal(self in ut_expectation_varchar2, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_equal(self in ut_expectation, a_expected varchar2)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_between(self in ut_expectation_varchar2, a_lower_bound varchar2, a_upper_bound varchar2) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_be_between(self in ut_expectation_varchar2, a_lower_bound varchar2, a_upper_bound varchar2)');
    self.to_( ut_be_between(a_lower_bound,a_upper_bound) );
  end;

  member procedure to_be_like(self in ut_expectation_varchar2, a_mask in varchar2, a_escape_char in varchar2 := null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 default null)');
    self.to_( ut_be_like(a_mask, a_escape_char) );
  end;

  member procedure to_match(self in ut_expectation_varchar2, a_pattern in varchar2, a_modifiers in varchar2 default null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 default null)');
    self.to_( ut_match(a_pattern, a_modifiers) );
  end;

end;
/
