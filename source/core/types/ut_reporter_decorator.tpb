create or replace type body ut_reporter_decorator is

  constructor function ut_reporter_decorator(a_decorated_reporter ut_reporter) return self as result is
  begin
    init(a_decorated_reporter);
    return;
  end ut_reporter_decorator;

  member procedure init(self in out nocopy ut_reporter_decorator, a_decorated_reporter ut_reporter) is
  begin
    self.decorated_reporter := a_decorated_reporter;
  end;

end;
/
