create or replace type body be_false as

  constructor function be_false(self in out nocopy be_false) return self as result is
  begin
    self.name := lower($$plsql_unit);
    self.expected := ut_data_value_boolean(false);
    return;
  end;

  overriding member function run_expectation(a_actual ut_data_value) return boolean is
  begin
    return
      case
        when a_actual is of (ut_data_value_boolean)
        then not ut_utils.int_to_boolean(treat(a_actual as ut_data_value_boolean).value)
        else (self as ut_expectation).run_expectation(a_actual)
      end;
  end;

end;
/
