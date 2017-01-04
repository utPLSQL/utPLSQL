create or replace type ut_execution_listener under ut_listener_interface
(
  reporters ut_reporters,
  constructor function ut_execution_listener(self in out nocopy ut_execution_listener, a_reporters ut_reporters) return self as result,
  overriding member procedure fire_before_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item),
  overriding member procedure fire_after_event(self in out nocopy ut_execution_listener, a_event_name varchar2, a_item ut_suite_item),
  overriding member procedure fire_event(self in out nocopy ut_execution_listener, a_event_timing varchar2, a_event_name varchar2, a_item ut_suite_item)
)
/
