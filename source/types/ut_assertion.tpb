create or replace type body ut_assertion as
  final member procedure build_assert_result(
    a_assert_result boolean, a_assert_name varchar2,
    a_expected_value_string in varchar2, a_expected_data_type varchar2 := null) is
  begin
    ut_utils.debug_log('ut_assertion.build_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || a_message);
    ut_assert_processor.add_assert_result(
      ut_assert_result(
        a_assert_name, ut_utils.to_test_result(a_assert_result),
        coalesce(a_expected_data_type, self.a_data_type), self.a_data_type, a_expected_value_string, a_actual_value_string, self.a_message
      )
    );
  end;
end;
/
