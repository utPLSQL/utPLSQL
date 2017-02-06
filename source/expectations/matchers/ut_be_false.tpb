create or replace type body ut_be_false as

  constructor function ut_be_false(self in out nocopy ut_be_false) return self as result is
  begin
    self.name := 'be false';
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_false, a_actual ut_data_value) return boolean is
  begin
    return
      case
        when a_actual is of (ut_data_value_boolean)
        then not ut_utils.int_to_boolean(treat(a_actual as ut_data_value_boolean).data_value)
        else (self as ut_matcher).run_matcher(a_actual)
      end;
  end;

end;
/
