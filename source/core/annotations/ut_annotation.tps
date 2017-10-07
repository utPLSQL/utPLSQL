create type ut_annotation as object(
  position           number(5,0),
  name               varchar2(1000),
  text               varchar2(4000),
  subobject_name     varchar2(250)
)
/

