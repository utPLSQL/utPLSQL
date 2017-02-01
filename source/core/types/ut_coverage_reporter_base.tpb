create or replace type body ut_coverage_reporter_base is

  overriding final member procedure before_calling_before_all(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_suite.object_owner), upper(a_suite.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_before_all (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

  overriding final member procedure before_calling_before_each(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_suite.object_owner), upper(a_suite.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_before_each (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

  overriding final member procedure before_calling_before_test(self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_test.object_owner), upper(a_test.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_before_test (self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

  overriding final member procedure before_calling_test_execute(self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_test.object_owner), upper(a_test.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_test_execute (self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

  overriding final member procedure before_calling_after_test(self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_test.object_owner), upper(a_test.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_after_test (self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

  overriding final member procedure before_calling_after_each(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_suite.object_owner), upper(a_suite.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_after_each (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

  overriding final member procedure before_calling_after_all(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
    ut_coverage.skip_coverage_for(ut_object_name(upper(a_suite.object_owner), upper(a_suite.object_name)));
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_after_all (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
      ut_coverage.coverage_pause();
      ut_coverage.coverage_flush();
  end;

end;
/
