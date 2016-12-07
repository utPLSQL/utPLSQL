create or replace type ut_documentation_reporter force under ut_reporter
(
  lvl                integer,
  test_count         integer,
  failed_test_count  integer,
  igonred_test_count integer,
  constructor function ut_documentation_reporter(self in out nocopy ut_documentation_reporter, a_output ut_output default ut_output_dbms_output()) return self as result,
  member function tab(self in ut_documentation_reporter) return varchar2,

  overriding member procedure print_text(self in out nocopy ut_documentation_reporter, a_text varchar2),
  overriding member procedure before_suite(self in out nocopy ut_documentation_reporter, a_suite ut_object),
  overriding member procedure before_test(self in out nocopy ut_documentation_reporter, a_test ut_object),
  overriding member procedure after_test(self in out nocopy ut_documentation_reporter, a_test ut_object),
  overriding member procedure after_suite(self in out nocopy ut_documentation_reporter, a_suite ut_object),
  overriding member procedure after_run(self in out nocopy ut_documentation_reporter, a_suites in ut_objects_list)

)
not final
/
