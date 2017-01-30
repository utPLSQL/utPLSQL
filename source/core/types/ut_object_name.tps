create or replace type ut_object_name as object (
  owner    varchar2(128),
  name     varchar2(128),
  map member function identity return varchar2
) final
/
