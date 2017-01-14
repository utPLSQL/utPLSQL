create or replace type ut_real_suite under ut_suite (
  /**
  * The procedure to be invoked before all of the items of the suite (executed once)
  * Procedure exists within the package of the suite
  */
  before_all   ut_executable,
  /**
  * The procedure to be invoked before each of the child items of the suite (executed each time for each item)
  * Procedure exists within the package of the suite
  */
  before_each  ut_executable,
  /**
  * The procedure to be invoked after each of the child items of the suite (executed each time for each item)
  * Procedure exists within the package of the suite
  */
  after_each   ut_executable,
  /**
  * The procedure to be invoked after all of the items of the suite (executed once)
  * Procedure exists within the package of the suite
  */
  after_all    ut_executable,
  constructor function ut_real_suite(
    self in out nocopy ut_real_suite, a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2, a_description varchar2 := null,
    a_path varchar2 := null, a_rollback_type integer := null, a_ignore_flag boolean := false, a_before_all_proc_name varchar2 := null,
    a_after_all_proc_name varchar2 := null, a_before_each_proc_name varchar2 := null, a_after_each_proc_name varchar2 := null
  ) return self as result,
  overriding member function is_valid return boolean,
  /**
  * Finds the item in the suite by it's name and returns the item index
  */
  overriding member function  do_execute(self in out nocopy ut_real_suite, a_listener in out nocopy ut_event_listener_base) return boolean
)
/
