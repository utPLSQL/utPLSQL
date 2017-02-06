create or replace type body ut_be_not_null as

  constructor function ut_be_not_null(self in out nocopy ut_be_not_null) return self as result is
  begin
    self.name := 'be not null';
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_not_null, a_actual ut_data_value) return boolean is
  begin
    return not a_actual.is_null;
  end;

end;
/
