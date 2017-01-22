create or replace type body ut_reporter_base is

  constructor function ut_reporter_base(self in out nocopy ut_reporter_base, a_output ut_output default ut_output_buffered()) return self as result is
  begin
    self.output := a_output;
    self.name := 'Null reporter';
    return;
  end;

  member procedure print_text(self in out nocopy ut_reporter_base, a_text varchar2) is
  begin
    self.output.send_line(a_text);
  end;

  member procedure print_clob(self in out nocopy ut_reporter_base, a_text clob) is
  begin
    self.output.send_clob(a_text);
  end;

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter_base, a_run in ut_run) is
  begin
    self.output.open();
  end;

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  member procedure before_calling_before_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;
  member procedure after_calling_before_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  member procedure before_calling_before_each(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;
  member procedure after_calling_before_each (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  -- test hooks
  member procedure before_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  member procedure before_calling_before_test(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;
  member procedure after_calling_before_test (self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  member procedure before_calling_test_execute(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;
  member procedure after_calling_test_execute (self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  member procedure before_calling_after_test(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;
  member procedure after_calling_after_test (self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  member procedure after_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  --suite hooks continued
  member procedure before_calling_after_each(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;
  member procedure after_calling_after_each (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  member procedure before_calling_after_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;
  member procedure after_calling_after_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  member procedure after_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter_base, a_run in ut_run) is
  begin
    self.output.close();
  end;
end;
/
