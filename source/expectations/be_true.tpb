create or replace type body be_true as

  constructor function be_true(self in out nocopy be_true) return self as result is
  begin
    self.assert_name := lower($$plsql_unit);
    self.expected := ut_data_value_boolean(true);
    return;
  end;

  overriding member function run_expectation(a_actual ut_data_value_boolean) return ut_assert_result is
  begin
    return self.build_assert_result(
      ut_utils.int_to_boolean(a_actual.value)
      , a_actual
    );
  end;

end;
/
