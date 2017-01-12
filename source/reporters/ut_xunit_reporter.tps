create or replace type ut_xunit_reporter under ut_reporter_base
(
  /**
   * The XUnit reporter.
   * Provides outcomes in a format conforming with JUnit4 as defined in:
   *  https://gist.github.com/kuzuha/232902acab1344d6b578
   */
  constructor function ut_xunit_reporter(a_output ut_output default ut_output_dbms_output()) return self as result,

  overriding member procedure after_calling_run(self in out nocopy ut_xunit_reporter, a_run in ut_run),
  member function get_common_item_attributes(a_item ut_suite_item) return varchar2
)
not final
/
