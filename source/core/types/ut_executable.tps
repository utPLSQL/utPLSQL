create or replace type ut_executable force as object
(
  /**
  * The name of the event to be executed before and after the executable is invoked
  */
  associated_event_name varchar2(250 char),
  owner_name            varchar2(250 char),
  object_name           varchar2(250 char),
  procedure_name        varchar2(250 char),
	constructor function ut_executable( self in out nocopy ut_executable, a_context ut_suite_item, a_procedure_name varchar2, a_associated_event_name varchar2) return self as result,
  member function is_valid return boolean,
  member function is_defined return boolean,
  member function form_name return varchar2,
  member procedure do_execute(self in ut_executable, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_listener_interface),
  /**
  * executes the defines executable
  * returns true if executed without exceptions
  * returns false if exceptions were raised
  */
  member function do_execute(self in ut_executable, a_item in out nocopy ut_suite_item, a_listener in out nocopy ut_listener_interface) return boolean
) final
/
