create or replace type ut_junit_reporter under ut_reporter_base
(
  constructor function ut_junit_reporter(a_output ut_output default ut_output_dbms_output()) return self as result,

  overriding member procedure after_calling_run(self in out nocopy ut_junit_reporter, a_run in ut_run),
  member function get_common_item_attributes(a_item ut_suite_item) return varchar2
)
not final
/
