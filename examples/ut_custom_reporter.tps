create or replace type ut_custom_reporter under ut_dbms_output_suite_reporter
(
  lvl integer,
  tab_size integer,

-- Member functions and procedures
  constructor function ut_custom_reporter(a_tab_size integer default 4) return self as result,
  member function tab(self in ut_custom_reporter) return varchar2,
  overriding member procedure print(msg varchar2),
  overriding member procedure before_suite(self in out nocopy ut_custom_reporter, a_suite ut_object),
  overriding member procedure before_test(self in out nocopy ut_custom_reporter, a_test ut_object),
  overriding member procedure on_assert_process(self in out nocopy ut_custom_reporter, a_assert ut_object),
  overriding member procedure after_test(self in out nocopy ut_custom_reporter, a_test ut_object),
  overriding member procedure after_suite(self in out nocopy ut_custom_reporter, a_suite ut_object)
)
not final
/
