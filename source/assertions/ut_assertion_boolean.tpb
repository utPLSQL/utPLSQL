create or replace type body ut_assertion_boolean as

  overriding member procedure to_equal(self in ut_assertion_boolean, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_assertion_boolean.to_equal(self in ut_assertion, a_expected boolean)');
    self.to_( equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_true(self in ut_assertion_boolean) is
    l_result boolean;
  begin
    l_result :=
    case when self.actual_data is of (ut_data_value_boolean)
      then ut_utils.int_to_boolean(treat(self.actual_data as ut_data_value_boolean).value)
      else false
    end;
    self.build_assert_result(
      l_result
      , 'to_be_true', ut_utils.to_string(true), 'boolean');
  end;

end;
/
