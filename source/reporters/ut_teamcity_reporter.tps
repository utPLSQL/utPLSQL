create or replace type ut_teamcity_reporter under ut_reporter_base
(
  constructor function ut_teamcity_reporter(self in out nocopy ut_teamcity_reporter) return self as result,

  overriding member procedure before_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_logical_suite),

  overriding member procedure after_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_logical_suite),

  overriding member procedure before_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test),

  overriding member procedure after_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test)
)
not final
/
