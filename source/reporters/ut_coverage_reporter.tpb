create or replace type body ut_coverage_reporter is

  constructor function ut_coverage_reporter(self in out nocopy ut_coverage_reporter, a_output ut_output default ut_output_dbms_output()) return self as result is
  begin
    self.name               := $$plsql_unit;
    self.output             := a_output;
    return;
  end;

  overriding member procedure before_calling_run(self in out nocopy ut_coverage_reporter, a_run ut_run) as
  begin
    (self as ut_reporter_base).before_calling_run(a_run);
    coverage_id := ut_coverage.profiler_start();
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coverage_reporter, a_run in ut_run) as
  begin
    ut_coverage.profiler_stop();
--    ut_coverage_reporter_helper.get_details_report();
    (self as ut_reporter_base).after_calling_run(a_run);
  end;

end;
/
