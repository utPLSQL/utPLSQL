create or replace type ut_coverage_reporter_base under ut_reporter_base
(
  overriding final member procedure before_calling_before_all(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),
  overriding final member procedure after_calling_before_all (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),

  overriding final member procedure before_calling_before_each(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),
  overriding final member procedure after_calling_before_each (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),

  overriding final member procedure before_calling_before_test(self in out nocopy ut_coverage_reporter_base, a_test in ut_test),
  overriding final member procedure after_calling_before_test (self in out nocopy ut_coverage_reporter_base, a_test in ut_test),

  overriding final member procedure before_calling_test_execute(self in out nocopy ut_coverage_reporter_base, a_test in ut_test),
  overriding final member procedure after_calling_test_execute (self in out nocopy ut_coverage_reporter_base, a_test in ut_test),

  overriding final member procedure before_calling_after_test(self in out nocopy ut_coverage_reporter_base, a_test in ut_test),
  overriding final member procedure after_calling_after_test (self in out nocopy ut_coverage_reporter_base, a_test in ut_test),

  overriding final member procedure before_calling_after_each(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),
  overriding final member procedure after_calling_after_each (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),

  overriding final member procedure before_calling_after_all(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite),
  overriding final member procedure after_calling_after_all (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite)

)
not final not instantiable
/
