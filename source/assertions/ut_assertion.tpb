create or replace type body ut_assertion as
  final member procedure build_assert_result( self in ut_assertion,  a_assert_result boolean, a_assert_name varchar2,
    a_expected_value_string in varchar2, a_expected_data_type varchar2 := null) is
  begin
    ut_utils.debug_log('ut_assertion.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || message);
    ut_assert_processor.add_assert_result(
      ut_assert_result(
        a_assert_name, ut_utils.to_test_result(a_assert_result),
        coalesce(a_expected_data_type, self.data_type), self.data_type, a_expected_value_string, self.actual_value_string, self.message
      )
    );
  end;

  member procedure to_be_equal(self in ut_assertion, a_expected varchar2) is
  begin
    self.build_assert_result( false, 'to be equal', ut_utils.to_string(a_expected), 'varchar2');
  end;

  member procedure to_be_equal(self in ut_assertion, a_expected number) is
  begin
    self.build_assert_result( false, 'to be equal', ut_utils.to_string(a_expected), 'number');
  end;

--  member procedure to_be_equal(self in ut_assertion, a_expected raw) is
--  begin
--    self.build_assert_result( false, 'to be equal', ut_utils.to_string(a_expected), 'raw');
--  end;

  final member procedure to_be_null is
  begin
    self.build_assert_result(ut_utils.int_to_boolean(self.is_null), 'to_be_null', null, ut_utils.to_string(to_char(null)));
  end;

  final member procedure to_be_not_null is
  begin
    self.build_assert_result(not ut_utils.int_to_boolean(self.is_null), 'to_be_not_null', null, ut_utils.to_string(to_char(null)));
  end;

end;
/
