create or replace type ut_suite_item as object (
  /**
  * owner of the database object (package)
  */
  object_owner  varchar2(4000),
  /**
  * name of the database object (package)
  */
  object_name   varchar2(4000),
  /**
  * Name of the object (suite, sub-suite, test)
  */
  name          varchar2(4000),
  /**
  * Description fo the suite item (as given by the annotation)
  */
  description   varchar2(4000),

  /**
  * Full path of the invocation of the item (including the items name itself)
  */
  path          varchar2(4000),
  /**
  * The type of the rollback behavior
  */
  rollback_type integer(1),
  /**
  * Indicates if the test is to be ignored by execution
  */
  ignore_flag   integer(1),
  --execution result fields
  start_time    timestamp with time zone,
  end_time      timestamp with time zone,
  result        integer(1),
  member procedure init(
    self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2,
    a_description varchar2, a_path varchar2, a_rollback_type integer, a_ignore_flag boolean),
  member procedure set_ignore_flag( self in out nocopy ut_suite_item, a_ignore_flag boolean),
  member function get_ignore_flag return boolean,
  member function create_savepoint_if_needed return varchar2,
  member procedure rollback_to_savepoint( self in ut_suite_item, a_savepoint varchar2),
  member function execution_time return number
)
not final not instantiable
/