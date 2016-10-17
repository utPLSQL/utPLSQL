create or replace type body ut_assertion as

  final member procedure add_assert_result( self in ut_assertion,  a_assert_result boolean, a_assert_name varchar2,
    a_assert_info varchar2, a_error_message varchar2, a_expected_value_string in varchar2 := null, a_expected_data_type varchar2 := null
  ) is
    l_assert_info varchar2(4000);
  begin
    l_assert_info := case when a_assert_info is not null then ' '||a_assert_info end;
    ut_utils.debug_log('ut_assertion.add_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || message);
    ut_assert_processor.add_assert_result(
      ut_assert_result(
        a_assert_name, l_assert_info, a_error_message, ut_utils.to_test_result(coalesce(a_assert_result,false)),
        a_expected_data_type, self.actual_data.type, a_expected_value_string, self.actual_data.to_string(), self.message
      )
    );
  end;

  member procedure to_equal(self in ut_assertion, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected blob, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected boolean, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected clob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected clob, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected date, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected sys_refcursor, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected sys_refcursor, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  member procedure to_equal(self in ut_assertion, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected varchar2, a_nulls_are_equal boolean := null)');
    self.to_( equal(a_expected) );
  end;

  final member procedure to_(self in ut_assertion, a_expectation ut_expectation) is
    l_assert_result boolean;
    l_assert_name   varchar2(4000);
    l_expectation   ut_expectation := a_expectation;
  begin
    ut_utils.debug_log('ut_assertion.to_(self in ut_assertion, a_expectation ut_expectation)');

    l_assert_result := l_expectation.run_expectation( self.actual_data );
    l_assert_name   := 'to '||l_expectation.name;
    if l_expectation.expected is not null then
      add_assert_result( l_assert_result, l_assert_name, l_expectation.additional_info, l_expectation.error_message
        , l_expectation.expected.to_string(), l_expectation.expected.type );
    else
      add_assert_result( l_assert_result, l_assert_name, l_expectation.additional_info, l_expectation.error_message );
    end if;
  end;

  final member procedure not_to(self in ut_assertion, a_expectation ut_expectation) is
    l_assert_result boolean;
    l_assert_name   varchar2(4000);
    l_expectation   ut_expectation := a_expectation;
  begin
    ut_utils.debug_log('ut_assertion.not_to(self in ut_assertion, a_expectation ut_expectation)');

    l_assert_result := not l_expectation.run_expectation( self.actual_data );
    l_assert_name   := 'not to '||l_expectation.name;
    if l_expectation.expected is not null then
      add_assert_result( l_assert_result, l_assert_name, l_expectation.additional_info, l_expectation.error_message
        , l_expectation.expected.to_string(), l_expectation.expected.type );
    else
      add_assert_result( l_assert_result, l_assert_name, l_expectation.additional_info, l_expectation.error_message );
    end if;
  end;

  final member procedure to_be_null(self in ut_assertion) is
  begin
    ut_utils.debug_log('ut_assertion.to_be_null');
    self.to_( be_null() );
  end;

  final member procedure to_be_not_null(self in ut_assertion) is
  begin
    ut_utils.debug_log('ut_assertion.to_be_not_null');
    self.to_( be_not_null() );
  end;

end;
/
