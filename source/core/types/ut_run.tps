create or replace type ut_run authid current_user under ut_suite_item (
  /**
  * The list of items (suites) to be invoked as part of this run
  */
  items        ut_suite_items,
  constructor function ut_run( self in out nocopy ut_run, a_items ut_suite_items ) return self as result,
  overriding member function  do_execute(self in out nocopy ut_run, a_listener in out nocopy ut_event_listener_base) return boolean,
  overriding member procedure calc_execution_result(self in out nocopy ut_run)
)
/
