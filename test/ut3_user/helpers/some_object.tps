create or replace type some_object force as object(
  object_owner     varchar2(250),
  object_name      varchar2(250),
  create_time      timestamp,
  items            some_items
)
/
