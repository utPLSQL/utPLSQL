create or replace type body be_true as

  constructor function be_true(self in out nocopy be_true) return self as result is
  begin
    self.name := lower($$plsql_unit);
    return;
  end;

  overriding member function run_matcher(self in out nocopy be_true, a_actual ut_data_value) return boolean is
  begin
    return
      case
        when a_actual is of (ut_data_value_boolean)
        then ut_utils.int_to_boolean( treat(a_actual as ut_data_value_boolean).data_value)
        else (self as ut_matcher).run_matcher(a_actual)
      end;
  end;

end;
/
