create or replace type ut_reporter force as object
(
  name   varchar2(250 char),
  output ut_output,
  constructor function ut_reporter(self in out nocopy ut_reporter, a_output ut_output default ut_output_dbms_output()) return self as result,

  member procedure print_text(self in out nocopy ut_reporter, a_text varchar2),
  member procedure print_clob(self in out nocopy ut_reporter, a_text clob),

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter, a_run in ut_run),
  
  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter, a_suite in ut_suite),
  
  member procedure before_calling_before_all(self in out nocopy ut_reporter, a_suite in ut_suite),
  member procedure after_calling_before_all (self in out nocopy ut_reporter, a_suite in ut_suite),
  
  member procedure before_calling_before_each(self in out nocopy ut_reporter, a_suite in ut_suite),
  member procedure after_calling_before_each (self in out nocopy ut_reporter, a_suite in ut_suite),
  
  -- test hooks
  member procedure before_calling_test(self in out nocopy ut_reporter, a_test in ut_test),
  
  member procedure before_calling_before_test(self in out nocopy ut_reporter, a_test in ut_test),
  member procedure after_calling_before_test (self in out nocopy ut_reporter, a_test in ut_test),
  
  member procedure before_calling_test_execute(self in out nocopy ut_reporter, a_test in ut_test),
  member procedure after_calling_test_execute (self in out nocopy ut_reporter, a_test in ut_test),
  
  member procedure before_calling_after_test(self in out nocopy ut_reporter, a_test in ut_test),
  member procedure after_calling_after_test (self in out nocopy ut_reporter, a_test in ut_test),
  
  member procedure after_calling_test(self in out nocopy ut_reporter, a_test in ut_test),
  
  --suite hooks continued
  member procedure before_calling_after_each(self in out nocopy ut_reporter, a_suite in ut_suite),
  member procedure after_calling_after_each (self in out nocopy ut_reporter, a_suite in ut_suite),
  
  member procedure before_calling_after_all(self in out nocopy ut_reporter, a_suite in ut_suite),
  member procedure after_calling_after_all (self in out nocopy ut_reporter, a_suite in ut_suite),
  
  member procedure after_calling_suite(self in out nocopy ut_reporter, a_suite in ut_suite),
  
  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter, a_run in ut_run)

)
not final
/
