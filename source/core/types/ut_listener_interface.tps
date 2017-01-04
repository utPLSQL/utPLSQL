create or replace type ut_listener_interface as object
(
  name varchar2(250),
  member procedure fire_before_event(self in out nocopy ut_listener_interface, a_event_name varchar2, a_item ut_suite_item),
  member procedure fire_after_event(self in out nocopy ut_listener_interface, a_event_name varchar2, a_item ut_suite_item),
  member procedure fire_event(self in out nocopy ut_listener_interface, a_event_timing varchar2, a_event_name varchar2, a_item ut_suite_item)
) not final not instantiable
/
