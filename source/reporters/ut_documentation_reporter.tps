create or replace type ut_documentation_reporter force under ut_reporter_base
(
  lvl                       integer,
  failed_test_running_count integer,
  constructor function ut_documentation_reporter(self in out nocopy ut_documentation_reporter, a_output ut_output default ut_output_buffered()) return self as result,
  member function tab(self in ut_documentation_reporter) return varchar2,

  overriding member procedure print_text(self in out nocopy ut_documentation_reporter, a_text varchar2),
  overriding member procedure before_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_test(self in out nocopy ut_documentation_reporter, a_test ut_test),
  overriding member procedure after_calling_suite(self in out nocopy ut_documentation_reporter, a_suite ut_logical_suite),
  overriding member procedure after_calling_run(self in out nocopy ut_documentation_reporter, a_run in ut_run)

)
not final
/
