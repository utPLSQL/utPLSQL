create or replace type ut_reporter force as object
(
  name   varchar2(250 char),
  output ut_output,
  constructor function ut_reporter(self in out nocopy ut_reporter, a_output ut_output default ut_output_dbms_output()) return self as result,

  member procedure print_text(self in out nocopy ut_reporter, a_text varchar2),
  member procedure print_clob(self in out nocopy ut_reporter, a_text clob),

  -- run hooks
  member procedure before_run(self in out nocopy ut_reporter, a_suites in ut_suite_items),
  member procedure after_run(self in out nocopy ut_reporter, a_suites in ut_suite_items),

  -- suite hooks
  member procedure before_suite(self in out nocopy ut_reporter, a_suite in ut_suite_item),

  member procedure before_suite_setup(self in out nocopy ut_reporter, a_suite in ut_suite_item),
  member procedure after_suite_setup(self in out nocopy ut_reporter, a_suite in ut_suite_item),

  member procedure before_suite_item(self in out nocopy ut_reporter, a_suite in ut_suite_item, a_item_index pls_integer),
  member procedure after_suite_item(self in out nocopy ut_reporter, a_suite in ut_suite_item, a_item_index pls_integer),

  member procedure before_suite_teardown(self in out nocopy ut_reporter, a_suite in ut_suite_item),
  member procedure after_suite_teardown(self in out nocopy ut_reporter, a_suite in ut_suite_item),

  member procedure after_suite(self in out nocopy ut_reporter, a_suite in ut_suite_item),

-- test hooks
  member procedure before_test(self in out nocopy ut_reporter, a_test in ut_suite_item),

  member procedure before_test_setup(self in out nocopy ut_reporter, a_test in ut_suite_item),
  member procedure after_test_setup(self in out nocopy ut_reporter, a_test in ut_suite_item),

  member procedure before_test_execute(self in out nocopy ut_reporter, a_test in ut_suite_item),
  member procedure after_test_execute(self in out nocopy ut_reporter, a_test in ut_suite_item),

  member procedure before_test_teardown(self in out nocopy ut_reporter, a_test in ut_suite_item),
  member procedure after_test_teardown(self in out nocopy ut_reporter, a_test in ut_suite_item),

  member procedure after_test(self in out nocopy ut_reporter, a_test in ut_suite_item)

)
not final
/
