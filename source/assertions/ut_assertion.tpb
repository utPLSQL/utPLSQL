create or replace type body ut_assertion as
  final member procedure build_assert_result( self in ut_assertion,  a_assert_result boolean, a_assert_name varchar2,
    a_expected_value_string in varchar2, a_expected_data_type varchar2 := null) is
  begin
    ut_utils.debug_log('ut_assertion.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || message);
    ut_assert_processor.add_assert_result(
      ut_assert_result(
        a_assert_name, ut_utils.to_test_result(a_assert_result),
        coalesce(a_expected_data_type, self.actual_data.type), self.actual_data.type, a_expected_value_string, self.actual_data.value_string, self.message
      )
    );
  end;

  member procedure to_equal(self in ut_assertion, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(xmltype(a_expected).getclobval()), 'anydata');
  end;

  member procedure to_equal(self in ut_assertion, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected blob, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'blob');
  end;

  member procedure to_equal(self in ut_assertion, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected boolean, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'boolean');
  end;

  member procedure to_equal(self in ut_assertion, a_expected clob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected clob, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'clob');
  end;

  member procedure to_equal(self in ut_assertion, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected date, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'date');
  end;

  member procedure to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'number');
  end;

  member procedure to_equal(self in ut_assertion, a_expected sys_refcursor, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected sys_refcursor, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(to_char(null)), 'refcursor');
  end;

  member procedure to_equal(self in ut_assertion, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'timestamp');
  end;

  member procedure to_equal(self in ut_assertion, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'timestamp with local time zone');
  end;

  member procedure to_equal(self in ut_assertion, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'timestamp with time zone');
  end;

  member procedure to_equal(self in ut_assertion, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion.to_equal(self in ut_assertion, a_expected varchar2, a_nulls_are_equal boolean := null)');
    self.build_assert_result( false, 'to_equal', ut_utils.to_string(a_expected), 'varchar2');
  end;

  member procedure to_(self in ut_assertion, a_expectation ut_expectation) is
    l_assert_result ut_assert_result;
  begin
    ut_utils.debug_log('ut_assertion.to_(self in ut_assertion, a_expectation ut_expectation)');
    l_assert_result :=
      case
        when self.actual_data is of (ut_data_value_anydata) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_anydata) )
        when self.actual_data is of (ut_data_value_blob) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_blob) )
        when self.actual_data is of (ut_data_value_boolean) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_boolean) )
        when self.actual_data is of (ut_data_value_clob) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_clob) )
        when self.actual_data is of (ut_data_value_date) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_date) )
        when self.actual_data is of (ut_data_value_number) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_number) )
        when self.actual_data is of (ut_data_value_refcursor) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_refcursor) )
        when self.actual_data is of (ut_data_value_timestamp) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_timestamp) )
        when self.actual_data is of (ut_data_value_timestamp_tz) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_timestamp_tz) )
        when self.actual_data is of (ut_data_value_timestamp_ltz) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_timestamp_ltz) )
        when self.actual_data is of (ut_data_value_varchar2) then a_expectation.run_expectation( treat(self.actual_data as ut_data_value_varchar2) )
      end;
    l_assert_result.message := self.message;
    l_assert_result.name    := 'to '||l_assert_result.name;
    ut_assert_processor.add_assert_result( l_assert_result );
  end;

  final member procedure to_be_null is
  begin
    ut_utils.debug_log('ut_assertion.to_be_null');
    self.build_assert_result(ut_utils.int_to_boolean(self.actual_data.is_null), 'to_be_null', null, ut_utils.to_string(to_char(null)));
  end;

  final member procedure to_be_not_null is
  begin
    ut_utils.debug_log('ut_assertion.to_be_not_null');
    self.build_assert_result(not ut_utils.int_to_boolean(self.actual_data.is_null), 'to_be_not_null', null, ut_utils.to_string(to_char(null)));
  end;

end;
/
