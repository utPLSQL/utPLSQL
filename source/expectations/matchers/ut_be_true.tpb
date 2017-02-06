create or replace type body ut_be_true as

  constructor function ut_be_true(self in out nocopy ut_be_true) return self as result is
  begin
    self.name := 'be true';
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_true, a_actual ut_data_value) return boolean is
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
