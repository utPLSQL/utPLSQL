create or replace type utplsql_test_reporter under ut_output_reporter_base(
  constructor function utplsql_test_reporter(self in out nocopy utplsql_test_reporter) return self as result,
  overriding member procedure after_calling_run(self in out nocopy utplsql_test_reporter, a_run in ut_run)
)
/

create or replace type body utplsql_test_reporter is
  constructor function utplsql_test_reporter(self in out nocopy utplsql_test_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy utplsql_test_reporter, a_run in ut_run) is
  begin
    self.print_text(a_run.result);
  end;
end;
/

