create or replace type body ut_expectation as
  final member function build_assert_result( self in ut_expectation, a_assert_result boolean, a_actual ut_data_value) return ut_assert_result is
  begin
    ut_utils.debug_log('ut_expectation.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':');
    return
      ut_assert_result(
        self.assert_name, ut_utils.to_test_result(a_assert_result),
        self.expected.type, a_actual.type,
        self.expected.value_string, a_actual.value_string, null
      );
  end;
end;
/
