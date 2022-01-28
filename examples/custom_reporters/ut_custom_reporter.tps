create or replace type ut_custom_reporter under ut_documentation_reporter
(
  tab_size integer,

-- Member functions and procedures
  constructor function ut_custom_reporter(a_tab_size integer default 4) return self as result,

  /* The reporter is using base functions of parent type ( UT_DOCUMENTATION_REPORTER )
     It is altering the behavior of the base functions by change of the indentation.
     So the custom reporter is same as documentation reporter except that the tab size is bigger.
     Additionally, the reporter constructor accepts parameter to indicate the indentation size
   */
  overriding member function tab(self in ut_custom_reporter) return varchar2,
  overriding member procedure print_text(a_text varchar2, a_item_type varchar2 := null),
  overriding member procedure before_calling_suite(self in out nocopy ut_custom_reporter, a_suite ut_logical_suite),
  overriding member procedure before_calling_test(self in out nocopy ut_custom_reporter, a_test ut_test),
  overriding member procedure after_calling_test(self in out nocopy ut_custom_reporter, a_test ut_test),
  overriding member procedure after_calling_suite(self in out nocopy ut_custom_reporter, a_suite ut_logical_suite)
)
not final
/
