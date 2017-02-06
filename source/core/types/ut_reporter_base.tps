create or replace type ut_reporter_base force authid current_user as object
(
  name   varchar2(250 char),
  output ut_output,
  constructor function ut_reporter_base(self in out nocopy ut_reporter_base, a_output ut_output default ut_output_dbms_output()) return self as result,

  member procedure print_text(self in out nocopy ut_reporter_base, a_text varchar2),
  member procedure print_clob(self in out nocopy ut_reporter_base, a_text clob),

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter_base, a_run in ut_run),

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_before_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_before_each(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_before_each (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  -- test hooks
  member procedure before_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_before_test(self in out nocopy ut_reporter_base, a_test in ut_test),
  member procedure after_calling_before_test (self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_test_execute(self in out nocopy ut_reporter_base, a_test in ut_test),
  member procedure after_calling_test_execute (self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure before_calling_after_test(self in out nocopy ut_reporter_base, a_test in ut_test),
  member procedure after_calling_after_test (self in out nocopy ut_reporter_base, a_test in ut_test),

  member procedure after_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test),

  --suite hooks continued
  member procedure before_calling_after_each(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_after_each (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure before_calling_after_all(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),
  member procedure after_calling_after_all (self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  member procedure after_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite),

  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter_base, a_run in ut_run)

)
not final not instantiable
/
