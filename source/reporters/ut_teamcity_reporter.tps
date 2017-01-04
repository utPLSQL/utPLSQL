create or replace type ut_teamcity_reporter under ut_reporter
(
  suite_names_stack ut_varchar2_list,
  constructor function ut_teamcity_reporter(a_output ut_output default ut_output_dbms_output()) return self as result,

  overriding member procedure before_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_suite),

  overriding member procedure after_calling_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_suite),

  overriding member procedure before_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test),

  overriding member procedure after_calling_test(self in out nocopy ut_teamcity_reporter, a_test in ut_test)
)
not final
/
