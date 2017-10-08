create type ut_annotated_object as object(
  object_owner                  varchar2(250),
  object_name                   varchar2(250),
  object_type                   varchar2(50),
  annotations                   ut_annotations
)
/

