create or replace type ut_execution_listener as object
(
  reporters ut_reporters,

  --generic hook
  member procedure fire_before_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item),
  member procedure fire_after_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item),
  member procedure fire_event(self in out nocopy ut_execution_listener, event_timing varchar2, a_event_name varchar2, a_item ut_suite_item),

  -- run hooks
  member procedure before_run(self in out nocopy ut_execution_listener, a_suites in ut_suite_items),
  member procedure after_run (self in out nocopy ut_execution_listener, a_suites in ut_suite_items),

  -- suite hooks
  member procedure before_suite(self in out nocopy ut_execution_listener, a_suite in ut_suite_item),

  member procedure before_calling_before_all(self in out nocopy ut_execution_listener, a_suite in ut_suite_item),
  member procedure after_calling_before_all (self in out nocopy ut_execution_listener, a_suite in ut_suite_item),

  member procedure before_suite_item(self in out nocopy ut_execution_listener, a_suite in ut_suite_item, a_item_index pls_integer),
  member procedure after_suite_item (self in out nocopy ut_execution_listener, a_suite in ut_suite_item, a_item_index pls_integer),

  member procedure before_calling_after_all(self in out nocopy ut_execution_listener, a_suite in ut_suite_item),
  member procedure after_calling_after_all (self in out nocopy ut_execution_listener, a_suite in ut_suite_item),

  member procedure after_suite(self in out nocopy ut_execution_listener, a_suite in ut_suite_item),

  -- test hooks
  member procedure before_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item),

  member procedure before_calling_before_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item),
  member procedure after_calling_before_test (self in out nocopy ut_execution_listener, a_test in ut_suite_item),

  member procedure before_calling_test_execute(self in out nocopy ut_execution_listener, a_test in ut_suite_item),
  member procedure after_calling_test_execute (self in out nocopy ut_execution_listener, a_test in ut_suite_item),

  member procedure before_calling_after_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item),
  member procedure after_calling_after_test (self in out nocopy ut_execution_listener, a_test in ut_suite_item),

  member procedure after_test(self in out nocopy ut_execution_listener, a_test in ut_suite_item)
)
/
