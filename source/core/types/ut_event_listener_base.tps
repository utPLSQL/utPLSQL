create or replace type ut_event_listener_base as object
(
  name varchar2(250),
  member procedure fire_before_event(self in out nocopy ut_event_listener_base, a_event_name varchar2, a_item ut_suite_item_base),
  member procedure fire_after_event(self in out nocopy ut_event_listener_base, a_event_name varchar2, a_item ut_suite_item_base),
  member procedure fire_event(self in out nocopy ut_event_listener_base, a_event_timing varchar2, a_event_name varchar2, a_item ut_suite_item_base)
) not final not instantiable
/
