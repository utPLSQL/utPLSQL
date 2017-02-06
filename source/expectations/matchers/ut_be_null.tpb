create or replace type body ut_be_null as

  constructor function ut_be_null(self in out nocopy ut_be_null) return self as result is
  begin
    self.name := 'be null';
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_null, a_actual ut_data_value) return boolean is
  begin
    return a_actual.is_null;
  end;

end;
/
