create or replace type ut_suite force under ut_suite_item (

  /**
  * The list of items (suites/sub-suites/contexts/tests) to be invoked as part of this suite
  */
  items        ut_suite_items,

  constructor function ut_suite(
    self in out nocopy ut_suite,a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_description varchar2 := null, a_path varchar2
  ) return self as result,
  member function is_valid return boolean,
  /**
  * Finds the item in the suite by it's name and returns the item index
  */
  member function item_index(a_name varchar2) return pls_integer,
  member procedure add_item(self in out nocopy ut_suite, a_item ut_suite_item),
  overriding member function  do_execute(self in out nocopy ut_suite, a_listener in out nocopy ut_event_listener_base) return boolean,
  overriding member procedure do_execute(self in out nocopy ut_suite, a_listener in out nocopy ut_event_listener_base),
  overriding member procedure calc_execution_result(self in out nocopy ut_suite)
) not final
/
