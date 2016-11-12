create or replace type body be_null as

  constructor function be_null(self in out nocopy be_null) return self as result is
  begin
    self.name := lower($$plsql_unit);
    return;
  end;

  overriding member function run_matcher(self in out nocopy be_null, a_actual ut_data_value) return boolean is
  begin
    return a_actual.is_null;
  end;

end;
/
