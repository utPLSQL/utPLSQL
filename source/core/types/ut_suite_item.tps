create or replace type ut_suite_item under ut_suite_item_base (

  member procedure init(
    self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2,
    a_description varchar2, a_path varchar2, a_rollback_type integer, a_ignore_flag boolean),
  member procedure set_ignore_flag(self in out nocopy ut_suite_item, a_ignore_flag boolean),
  member function get_ignore_flag return boolean,
  member function create_savepoint_if_needed return varchar2,
  member procedure rollback_to_savepoint(self in ut_suite_item, a_savepoint varchar2),
  member function execution_time return number,
  
  not instantiable member function  do_execute(self in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) return boolean,
  not instantiable member procedure do_execute(self in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base)

)
not final not instantiable
/
