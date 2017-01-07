create or replace type ut_suite_item_base as object (

  /**
  * Object type is a pre-declaration to be referenced by ut_event_listener_base
  * The true abstract type is ut_suite_item
  */
  self_type    varchar2(250 byte),
  /**
  * owner of the database object (package)
  */
  object_owner  varchar2(4000 byte),
  /**
  * name of the database object (package)
  */
  object_name   varchar2(4000 byte),
  /**
  * Name of the object (suite, sub-suite, test)
  */
  name          varchar2(4000 byte),
  /**
  * Description fo the suite item (as given by the annotation)
  */
  description   varchar2(4000 byte),

  /**
  * Full path of the invocation of the item (including the items name itself)
  */
  path          varchar2(4000 byte),
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
  result        integer(1)

)
not final not instantiable
/
