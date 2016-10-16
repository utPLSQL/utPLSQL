create or replace type body be_not_null as

  constructor function be_not_null(self in out nocopy be_not_null) return self as result is
  begin
    self.name := lower($$plsql_unit);
    return;
  end;

  overriding member function run_expectation(a_actual ut_data_value) return boolean is
  begin
    return not a_actual.is_null;
  end;

end;
/
