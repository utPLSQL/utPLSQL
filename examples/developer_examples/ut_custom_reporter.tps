create or replace type ut_custom_reporter under ut_documentation_reporter
(
  tab_size integer,

-- Member functions and procedures
  constructor function ut_custom_reporter(a_tab_size integer default 4, a_output ut_output default ut_output_dbms_output() ) return self as result,
  overriding member function tab(self in ut_custom_reporter) return varchar2,
  overriding member procedure print_text(a_text varchar2),
  overriding member procedure before_calling_suite(self in out nocopy ut_custom_reporter, a_suite ut_logical_suite),
  overriding member procedure before_calling_test(self in out nocopy ut_custom_reporter, a_test ut_test),
  overriding member procedure after_calling_test(self in out nocopy ut_custom_reporter, a_test ut_test),
  overriding member procedure after_calling_suite(self in out nocopy ut_custom_reporter, a_suite ut_logical_suite)
)
not final
/
